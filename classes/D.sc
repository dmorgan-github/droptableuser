/*
NOTE: can record with nodeproxy
https://doc.sccode.org/Classes/RecNodeProxy.html
*/

// using Ndef so we can use JitLib UIs
D : Ndef {

    classvar <>defaultout;

    var <vstctrls, <>color;

    var <fxchain, <metadata;

    var <cmdperiodfunc;

    *new {|key, source|

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

        if (source.notNil) {
            res.put(0, source)
        };

        // initialize or re-initialize
        res.filter(1000, {|in|
            var sig = in;
            sig = Sanitize.ar(sig);
            SafetyLimiter.ar(LeakDC.ar(sig));
        });

        res.filter(1010, {|in|
            Splay.ar(
                in * \vol.kr(1, spec:ControlSpec(0, 2, \lin, 0, 1, "vol")),
                spread: \spread.kr(1),
                center: \pan.kr(0)
            );
        });

        ^res;
    }

    node {
        ^this
    }

    print {

        //this.fxchain.asCode.postln;
        this.fxchain.do({|v, i|
            var name = v.name;
            if (v.type == 'vst') {
                name = "vst/%".format(name);
            };
            "D('%').fx(%, '%')".format(this.key, i, name).postln;
        });

        "(\nD('%').set(".format(this.key).postln;
        this.nodeMap.getPairs.pairsDo({|k, v|
            if (this.internalKeys.includes(k).not) {
                "\t".post;
                k.asCode.post;
                ", ".post;
                v.asCode.post;
                ",".postln;
            }
        });
        ")\n)".postln;

        //"(\nD('%').set(".format(this.key).postln;
        this.fxchain.do({|fx|
            if (fx.type == \vst) {
                V.getPatternParams(fx.name, fx.ctrl, {|vals|
                    "(\nD('%').set(".format(this.key).postln;
                    vals.do({|val|
                        "\t".post;
                        val.key.asCode.post;
                        ", ".post;
                        val.value.asCode.post;
                        ",".postln;
                    });
                    ")\n)".postln;
                });
                //"".postln;
            }
        });
        //")\n)".postln;
    }

    prInit {|argKey|

        vstctrls = Order.new;
        color = Color.rand;
        fxchain = Order.new;
        metadata = ();

        cmdperiodfunc = {
            {
                this.send;
                {
                    this.objects.doRange({|obj, index, i|
                        var hasvst = obj.synthDef.children.select({|ctrl| ctrl.isKindOf(VSTPlugin) }).size > 0;
                        if (hasvst) {
                            var synthdef = obj.synthDef;
                            var nodeId = obj.nodeID;
                            var synth = Synth.basicNew(synthdef.name, Server.default, nodeId);
                            var ctrl = VSTPluginController(synth, synthDef:synthdef);
                            ctrl.open(ctrl.info.key, verbose: true, editor:true);
                            fxchain[index]['ctrl'] = ctrl;
                        }
                    })
                }.defer(2)
            }.defer(1)
        };

        CmdPeriod.add(cmdperiodfunc);

        ^this.deviceInit;
    }

	*doesNotUnderstand {|selector|
		^this.new(selector);
	}

    put {|index, obj, channelOffset = 0, extraArgs, now = true|
        super.put(index, obj, channelOffset, extraArgs, now);
        {
            this.specs
            .keysValuesDo({|key, value|
                this.addSpec(key, value)
            })
        }.defer(0.5)
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

    fx {|index, fx, wet=1, env|

        if (fx.isNil) {
            this.removeAt(index);
            this.fxchain.removeAt(index);
        }{
            var specs;
            if (fx.isFunction) {
                this.filter(index, fx);
                this.fxchain.put(index, (name:"func_%".format(UniqueID.next), type:'func'));
            }{
                var num = {
                    var num;
                    var size = this.fxchain.select({|obj| obj.name == fx }).size;
                    if (size > 0) {
                        num = size+1;
                    };
                    num;
                }.();

                if (fx.asString.beginsWith("vst/")) {
                    var vst = fx.asString.split($/)[1..].join("/").asSymbol;
                    this.vst(index, vst, cb:{|ctrl|
                        vstctrls.put(index, ctrl);
                        this.fxchain.put(index, (name:vst, type:'vst', 'ctrl':ctrl));
                    });
                }{
                    var obj = Module("fx/%".format(fx).asSymbol);
                    var func = obj.put('num', num).func;
                    this.filter(index, func);
                    this.fxchain.put(index, (name:fx, type:'func', 'ctrl':obj));
                };
            };

            if (specs.isNil or: {specs.isEmpty}) {
                {
                    specs = this.objects[index].specs;
                    if (specs.isNil.not) {
                        this.addSpec(*specs.getPairs);
                    };
                }.defer(1)
            } {
                this.addSpec(*specs);
            };

            this.addSpec("wet%".format(index).asSymbol, [0, 1, \lin, 0, 1].asSpec);
            this.set("wet%".format(index).asSymbol, wet);
        }
    }

    vst {|index, vst, id, cb|

        var node = this;

        if (vst.isNil) {
            node.removeAt(index);
        }{
            var mykey = node.key ?? "n%".format(node.identityHash.abs);
            var vstkey = vst.asString.select({|val| val.isAlphaNum});
            var nodekey = mykey.asString.replace("/", "_");
            var key = "%_%".format(nodekey, vstkey).toLower.asSymbol;
            var server = Server.default;
            var nodeId, ctrl;

            {
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
                                VSTPlugin.ar(in, 2, id:id, info:vst.asSymbol);
                            }{
                                VSTPlugin.ar(in, 2, info:vst.asSymbol);
                            }
                        });
                    };

                    // there is latency for the synth to get initialized
                    // i can't figure out a better way than to wait
                    0.5.wait;
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

                ctrl.open(vst, editor:true, verbose: true, action:{
                    "loaded %".format(key).postln;
                    if (cb.isNil.not) {
                        cb.value(ctrl);
                    }
                });

            }.fork
        }
    }

    view {|index|
        ^U(\sgui, this);
    }

    gui {
        this.view.front
    }

    rec {|beats=4, preLevel=0, cb|

        // how to coordinate clocks?
        var clock = TempoClock.default;
        var seconds = clock.beatDur * beats;
        var id = "%_%".format(this.key, UniqueID.next).asSymbol;
        var buf = B.alloc(id, seconds * Server.default.sampleRate, 1);
        var bus = this.bus;
        var group = this.group;

        clock.schedAbs(clock.nextTimeOnGrid(1), {

            var synth = Synth(\rec, [\buf, buf, \in, bus, \preLevel, preLevel, \run, 1], target:group, addAction:\addToTail);
            synth.onFree({
                {
                    buf = B.all[id] = buf.normalize;
                    "buffer saved to %".format(id).postln;
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
