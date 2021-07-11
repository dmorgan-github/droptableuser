/*
NOTE: can record with nodeproxy
https://doc.sccode.org/Classes/RecNodeProxy.html
*/
D : NodeProxy {

    classvar <all, <>defaultout;

    var <chain, <vstctrls;

    var <>key;

    *new {|key|

        var res;

        if (key.isNil) {
            Error("key is required").throw;
        };

        res = all[key];

        if (res.isNil) {

            res = super.new(Server.default, rate:\audio, numChannels:2)
            .prInit(key);

            res.wakeUp;
            res.vol = 1;
            res.postInit;

            res.filter(1000, {|in|
                var sig = Select.ar(CheckBadValues.ar(in, 0, 0), [in, DC.ar(0), DC.ar(0), in]);
                Limiter.ar(LeakDC.ar(sig));
            });

            ServerTree.add({
                \cmdperiod.debug(key);
                res.send;
                if (res.isPlaying) {
                    res.play
                };
            });

            // if we're using a synthdef as a source
            // copy the specs if they are defined
            res.addDependant({|node, what, args|
                if (what == \source) {
                    var obj = args[0];
                    //"source detected".debug(key);
                    if (obj.isKindOf(Symbol)) {
                        var def = SynthDescLib.global.at(obj);
                        if (def.notNil) {
                            if (def.metadata.notNil and: {def.metadata[\specs].notNil}) {
                                "adding specs from % synthdef".format(obj).debug(key);
                                def.metadata[\specs].keysValuesDo({|k, v|
                                    node.addSpec(k, v.asSpec);
                                });
                            }
                        }
                    }
                }
            });

            res.monitor.out = defaultout;
            all[key] = res;
        };

        ^res;
    }

    prInit {|argKey|
        key = argKey;
        chain = Order.new;
        vstctrls = Order.new;
        ^this.deviceInit
    }

	*doesNotUnderstand {|selector|
		^this.new(selector);
	}

    // syntactic sugar
    @ {|val, adverb|

        if (val.isKindOf(Association)) {

            var prop = adverb;
            var num = val.key;

            // would like to find a better way to do this
            if (val.value.isNil) {
                var cckey = Twister.knobs(num).cckey;
                Evt.off(cckey, key);
                this.pset(prop, nil);
            }{
                var spec = val.value.asSpec;
                var node = Ndef("midi_%_%".format(key, prop).asSymbol, {\val.kr(spec.default)});
                var ccdefault = spec.default.linlin(spec.minval, spec.maxval, 0, 127);
                var cckey = Twister.knobs(num).cckey;
                Evt.on(cckey, key, {|data|
                    var val = data[\val];
                    node.set(\val, spec.map(val))
                });
                this.set(prop, node);
                this.changed(\midiknob, num, prop, spec);
            }

        } {
            if (val.isFunction) {
                var lfo;
                var key = "lfo_%".format(this.key);
                var lfokey = (key ++ '_' ++ adverb).asSymbol;
                "creating lfo node %".format(lfokey).debug(this.key);
                val = Ndef(lfokey, val);
                this.set(adverb, val);
            };
        }
    }

    /*
    | {|val, adverb|
        if (val.isNil) {
            var num = adverb.asInteger;
            var cckey = Twister.knobs(num).cckey;
            Evt.off(cckey, key);
        } {
            if (val.isKindOf(Association)) {
                var num = adverb.asInteger;
                var prop = val.key;
                var spec = val.value.asSpec;
                var node = Ndef("midi_%_%".format(key, prop).asSymbol, {\val.kr(spec.default)});
                //var ccdefault = spec.default.linlin(spec.minval, spec.maxval, 0, 127);
                var cckey = Twister.knobs(num).cckey;
                Evt.on(cckey, key, {|data|
                    var val = data[\val];
                    node.set(\val, spec.map(val))
                });
                this.set(prop, node);
                this.changed(\midiknob, num, prop, spec);
            };
        }
    }
    */

    deviceInit {
        // override to initialize
    }

    postInit {
        // override to initialize after init
    }

    out_ {|bus=0|
        this.monitor.out = bus;
    }

    fx {|index, fx, wet=1|

        if (fx.isNil) {
            this[index] = nil;
            this.chain.removeAt(index);
        }{
            var info = (
                key: fx,
            );

            if (fx.isFunction) {
                this.filter(index, fx);
                info[\key] = "fx_%".format(index).asSymbol;
            }{
                if (fx.asString.beginsWith("vst/")) {
                    var vst = fx.asString.split($/)[1..].join("/").asSymbol;
                    this.vst(index, vst, cb:{|ctrl|
                        vstctrls.put(index, ctrl);
                    });
                }{
                    var obj = N.loadFx(fx);
                    var func = obj[\synth];
                    var specs = obj[\specs];
                    var customui = obj[\ui];
                    this.filter(index, func);
                    if (specs.isNil.not) {
                        info[\specs] = ();
                        specs.do({|assoc|
                            this.addSpec(assoc.key, assoc.value);
                            info[\specs][assoc.key] = assoc.value;
                        });
                    };
                    info[\customui] = customui;
                };
            };
            this.addSpec("wet%".format(index).asSymbol, [0, 1, \lin, 0, 1].asSpec);
            this.set("wet%".format(index).asSymbol, wet);

            // defer to accommodate latency for vst
            {
                if (info[\specs].isNil) {
                    var def = this.objects[index];//.synthDef
                    var controls = def.controlNames.reject({|cn| this.internalKeys.includes(cn.name) });
                    var specs = ();
                    controls.do({|cn|
                        var key = cn.name;
                        var spec = if (this.specs[key].notNil){
                            this.specs[key];
                        }{
                            if (Spec.specs[key].notNil) {
                                Spec.specs[key]
                            }{
                                [0, 1].asSpec
                            }
                        };
                        specs[key] = spec;
                    });
                    info[\specs] = specs;
                };
                info[\specs]["wet%".format(index).asSymbol] = [0, 1, \lin, 0, 1].asSpec;

                this.chain.put(index, info);
                "added % at index %".format(fx, index).postln;
            }.defer(1)
        }
    }

    vst {|index, vst, id, cb|

        var node = this;

        if (vst.isNil) {
            node[index] = nil;
        }{
            var mykey = node.key ?? "n%".format(node.identityHash.abs);
            var vstkey = vst.asString.select({|val| val.isAlphaNum});
            var nodekey = mykey.asString.replace("/", "_");
            var key = "%_%".format(nodekey, vstkey).toLower.asSymbol;
            var server = Server.default;
            var nodeId, ctrl;

            Routine({

                if (node.objects[index].isNil) {

                    var path = App.librarydir ++ "vst/" ++ vst.asString ++ ".scd";
                    var pathname = PathName(path.standardizePath);
                    var fullpath = pathname.fullPath;

                    if (File.exists(fullpath)) {
                        var name = pathname.fileNameWithoutExtension;
                        var obj = File.open(fullpath, "r").readAllString.interpret;
                        node.filter(index, obj[\synth]);
                    } {
                        node.filter(index, {|in|
                            if (id.isNil.not) {
                                VSTPlugin.ar(in, 2, id:id);
                            }{
                                VSTPlugin.ar(in, 2);
                            }
                        });
                    };
                    1.wait;
                };

                nodeId = node.objects[index].nodeID;
                ctrl = if (node.objects[index].class == SynthDefControl) {
                    var synthdef = node.objects[index].synthDef;
                    var synth = Synth.basicNew(synthdef.name, server, nodeId);
                    if (id.isNil.not) {
                        VSTPluginController(synth, id:id, synthDef:synthdef);
                    }{
                        VSTPluginController(synth, synthDef:synthdef);
                    }
                }{
                    var synth = Synth.basicNew(vst, server, nodeId);
                    if (id.isNil.not) {
                        VSTPluginController(synth, id:id);
                    }{
                        VSTPluginController(synth);
                    }
                };
                ctrl.open(vst, verbose: true, editor:true);
                "loaded %".format(key).postln;
                if (cb.isNil.not) {
                    cb.value(ctrl);
                }{
                    currentEnvironment[key] = ctrl;
                }

            }).play;
        }
    }

    appendFx {|fx|
        var slot = this.objects
        .indices
        .select({|val| val >= 200 and: {val < 300}  }).maxItem ?? {199};
        slot = slot + 1;
        this.fx(slot, fx);
    }

    view {|index|
        U(\ngui, this);

        /*
        if (index.isNil) {
            U(\ngraph, this);
        }{
            var specs = this.chain[index][\specs];
            var uifunc = this.chain[index][\customui];
            U(\ngui, this, uifunc.(this), specs);
        }
        */
    }

    rec {|beats=4, preLevel=0, cb|

        // how to coordinate clocks?
        var clock = TempoClock.default;
        var seconds = clock.beatDur * beats;
        var buf = B.alloc("%_%".format(this.key, UniqueID.next).asSymbol, seconds * Server.default.sampleRate, 1);
        var bus = this.bus;
        var group = this.group;

        clock.schedAbs(clock.nextTimeOnGrid(1), {

            var synth = Synth(\rec, [\buf, buf, \in, bus, \preLevel, preLevel, \run, 1], target:group, addAction:\addToTail);
            synth.onFree({
                {
                    "buffer saved to %".format(this.key).postln;
                    cb.(buf);
                }.defer
            });
            nil;
        });
    }

    *initClass {

        all = IdentityDictionary.new;
        defaultout = 4;

        StartUp.add({
            SynthDef(\rec, {
                var buf = \buf.kr(0);
                var in = In.ar(\in.kr(0), 2).asArray.sum;
                var sig = RecordBuf.ar(in, buf,
                    \offset.kr(0),
                    \recLevel.kr(1),
                    \preLevel.kr(0),
                    \run.kr(1),
                    \loop.kr(0),
                    1,
                    doneAction:Done.freeSelf);
                Out.ar(0, Silent.ar(2));
            }).add;

        });
    }
}