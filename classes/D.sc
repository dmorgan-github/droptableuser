/*
NOTE: can record with nodeproxy
https://doc.sccode.org/Classes/RecNodeProxy.html
*/

// using Ndef so we can use JitLib UIs
D : Ndef {

    classvar <>defaultout;

    var <vstctrls;

    *new {|key|

        var res;

        if (key.isNil) {
            Error("key is required").throw;
        };

        res = Ndef.dictFor(Server.default).envir[key];

        if (res.isNil) {

            res = super.new(key).prInit();
            res.mold(2, \audio);
            res.wakeUp;
            res.vol = 1;
            res.postInit;

            res.filter(1000, {|in|
                var sig = Select.ar(CheckBadValues.ar(in, 0, 0), [in, DC.ar(0), DC.ar(0), in]);
                SafetyLimiter.ar(LeakDC.ar(sig));
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
                                //"adding specs from % synthdef".format(obj).debug(key);
                                def.metadata[\specs].keysValuesDo({|k, v|
                                    node.addSpec(k, v.asSpec);
                                });
                            }
                        }
                    }
                }
            });

            res.monitor.out = defaultout;
        };

        ^res;
    }

    prInit {|argKey|
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
                var node = Ndef("midi_%_%".format(key, prop).asSymbol.postln, {\val.kr(spec.default)});
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
            } {
                this.set(adverb, val)
            }
        }
    }

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
            this.removeAt(index);
        }{
            if (fx.isFunction) {
                this.filter(index, fx);
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
                    this.addSpec(*specs);
                };
            };
            this.addSpec("wet%".format(index).asSymbol, [0, 1, \lin, 0, 1].asSpec);
            this.set("wet%".format(index).asSymbol, wet);
        }
    }

    // TODO: add specs
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

        defaultout = 0;

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
