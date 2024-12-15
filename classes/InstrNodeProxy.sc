N : InstrNodeProxy {
}

InstrNodeProxy : Ndef {

    classvar <>defaultout;
    //var <vstctrls, 
    var <>color;
    var <inserts, <metadata;
    var <cmdperiodfunc;
    var <msgFunc;
    var <recnodeproxy, <recpath;
    var skipJack;

    *new {|key, source|
        var res;
        res = Ndef.dictFor(Server.default).envir[key];
        if (res.isNil) {
            res = super.new(key, source).prNodeInit();
        };
        if (source.notNil) {
            res.put(0, source)
        };
        ^res;
    }

    // fx inserts
    +> {|val, adverb|

        var offset = 20;
        if (adverb.notNil) {
            var index = offset + adverb.asInteger;
            this.fx(index, val); 
        }{
            if (val.isArray) {
                val.do({|v, i|
                    var index = offset + i;
                    this.fx(index, v);    
                })    
            }{
                this.fx(offset, val); 
            }
        }
    }

    // props
    @ {|val, adverb|
        this.setOrPut(adverb, val);
    }

    setOrPut {|prop, val|

        if (prop.isNil and: val.isKindOf(Array)) {
            this.set(*val);
        } {
            this.set(prop, val)
        }
    }

    record {|filename, quant|
        var dir = PathName(thisProcess.nowExecutingPath).pathOnly;
        recpath = dir +/+ filename;
		//if(server.serverRunning.not) { "server not running".inform; ^nil };
		recnodeproxy = RecNodeProxy.newFrom(this, 2);
		recnodeproxy.open(recpath, "WAV", "int24");
		recnodeproxy.record(paused:false, quant: quant)
		^recnodeproxy
	}

    stopRecording {|numbeats=4, normalize=true|

        var clock;
        var sr;
        var numframes;

        recnodeproxy.close;
        
        clock = TempoClock.default;
        sr = Server.default.sampleRate;
        numframes = (clock.beatDur * numbeats) * sr;

        Routine({
            var buf, onsets;
            var start = 0;
            var result;
            var dest, pn;
            var def = B.read(recpath, channels: [0, 1], normalize:false);
            
            def.wait;
            buf = def.value;

            def = B.onsets(buf.value);
            def.wait;
            onsets = def.value;
            start = onsets[0];

            buf.write(recpath, headerFormat: "wav", sampleFormat: "int24", numFrames: numframes, startFrame: start);
            pn = PathName(recpath);
            dest = "%%-3db.wav".format(pn.pathOnly, pn.fileNameWithoutExtension) ;

            Sox().norm(-3).transform(recpath, dest, replace:true);
            Sox.stats(dest);

        }).play;
        //B.b1.write("/Users/david/Documents/supercollider/projects/tapes/rings_110bpm_2.wav", headerFormat: "wav", sampleFormat: "int24", numFrames: ~numsamples, startFrame: 1536)
        ^nil;
    }

    // alternate way 
    rec {|seconds=8, numchannels=2, cb|
        var server = Server.default;
        var node = this.node;
        var synth = "instrproxyrecorder%".format(numchannels).asSymbol.debug("synth");
        Buffer.alloc(server, server.sampleRate * seconds, numchannels, completionMessage: {|buf|
            Synth.tail(node.group.nodeID, synth, [\buf, buf, \bus, node.bus.index])
            .onFree({
                "recoding done".debug(this.class.asString);
                cb.value(buf.normalize);
            })
        }); 
        ^nil
    }

    mute {|fadeTime=1|
        this.stop(fadeTime:fadeTime)
    }

    unmute {|fadeTime=1|
        this.play(fadeTime:fadeTime)
    }

    view {|cmds|
        ^UiModule('instr2').(this, nil, cmds);
    }

    gui {|cmds|
        this.view(cmds).front
    }

    clear {
        this.changed(\clear);
        "stop skipjack".debug("InstrNodeProxy");
        skipJack.stop;
        "remove cmdperiodfunc".debug("InstrNodeProxy");
        CmdPeriod.remove(cmdperiodfunc);
        //"vstctrls.clear".debug("InstrNodeProxy");
        //vstctrls.clear;
        "inserts.clear".debug("InstrNodeProxy");
        inserts.clear;
        "metadata.clear".debug("InstrNodeProxy");
        metadata.clear;
        "releaseDependants".debug("InstrNodeProxy");
        this.releaseDependants;
        "ndef remove".debug("InstrNodeProxy");
        Ndef.dictFor(Server.default).envir.removeAt(key);
        "super.clear".debug("InstrNodeProxy");
        ^super.clear;
    }

    node {
        // this is to help make this class
        // interchangable with InstrProxy in gui modules
        // without having to always check for IsKindOf(...)
        ^this
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

    out_ {|bus=0|
        //TODO: is this the best way to do this?
        var val;
        var outOffset = Server.default.options.numInputBusChannels;
        if (bus.isKindOf(Symbol)) {
            val = bus.asString[1..].asInteger;
            val = 2 * (val-1);
        } {
            val = bus;
        };
        val = outOffset + val;
        this.monitor.out = val.debug("out")        
    }

    out {
        ^this.monitor.out
    }

    getSpec {
        ^this.specs;
    }

    addSpec {|...pairs|
        if (pairs.notNil) {
			pairs.pairsDo { |name, spec|
				if (spec.notNil) { spec = spec.asSpec };
                this.specs.put(name, spec)
			}
		};
    }

    vst {|index, vst|

        var node = this;
        index.debug("InstrNodeProxy::vst::index");
        if (vst.isNil) {
            node.removeAt(index);
            node.inserts.removeAt(index);
        }{
            var mykey = node.key ?? "n%".format(node.identityHash.abs);
            var vstkey = vst.asString.select({|val| val.isAlphaNum});
            var nodekey = mykey.asString.replace("/", "_");
            var key = "%_%".format(nodekey, vstkey).toLower.asSymbol;
            var nodeId, ctrl;
            var oscfunc, onload;

            var server = Server.default;
            var path, split;
            var now = SystemClock.seconds;
            var filterfunc = {|in| VSTPlugin.ar(in, 2, info:vst);};

            split = vst.asString.split($/);
            vst = split[0].asSymbol;
            path = split[1];//.asString.debug("path1");
            if (path.isNil ) {
                path = key.asString;
            } {
                path = path.asString;   
            };
            path = path.resolveRelative.debug("path");
            
            // add the vst insert
            node.filter(index, filterfunc);
    
            onload = {|ctrl|
                var obj = (name:vst, type:'vst', 'ctrl':ctrl, 'params': Order(), path:path, view:{ ctrl.editor });
                if (File.exists(path)) {
                    ctrl.readProgram(path);
                };
                node.inserts.put(index, obj);
            };
    
            // wire up with plugin controller
            oscfunc = {
                nodeId = node.objects[index].nodeID;
                ctrl = if (node.objects[index].class == SynthDefControl) {
                    var synthdef = node.objects[index].synthDef;
                    var synth = Synth.basicNew(synthdef.name, server, nodeId);    
                    VSTPluginController(synth, synthDef:synthdef);
                }{
                    var synth = Synth.basicNew(vst, server, nodeId);
                    VSTPluginController(synth);
                };
    
                ctrl.open(vst, editor:true, verbose: true, action:{|ctrl|
                    "loaded %".format(key).postln;
                    onload.(ctrl);
                });
            };
    
            // adapted from: https://scsynth.org/t/jitlib-how-to-know-if-a-nodeproxy-is-fully-ready/9941?u=droptableuser
            OSCFunc({
                (SystemClock.seconds - now).debug("seconds to open synth");
                oscfunc.();
            }, '/n_go', server.addr, argTemplate: [node.objects[index].nodeID] ).oneShot;
        }
    }

    fx {|index, fx, cb, wet=1|

        if (fx.isNil) {
            this.removeAt(index);
            this.inserts.removeAt(index);
        }{
            var specs;
            if (fx.isFunction) {
                var obj = (name:"func_%".format(UniqueID.next), type:'func');
                obj['ui'] = {|self|
                    UiModule('instr').gui(this, index);
                };
                this.filter(index, fx);
                this.inserts.put(index, obj);
            }{
                if (fx.asString.beginsWith("vst:")) {

                    var vst;
                    vst = fx.asString.split($:)[1..].join("/").asSymbol;
                    this.vst(index, vst);

                }{
                    var func, mod, obj;
                    var key;// = "fx/%".format(fx).asSymbol;

                    try {
                        if (fx.isKindOf(Module)) {
                            mod = fx;
                            key = mod.key;
                        } {
                            key = "fx/%".format(fx).asSymbol;
                            mod = Module(key);
                        };
                        
                        obj = (name:key, type:'func', 'ctrl':mod);
                        obj['ui'] = {|self|
                            UiModule('instr').gui(this, index);
                        };
                        cb.(mod);
                        func = mod.func;
                        this.filter(index, func);
                        this.inserts.put(index, obj);

                    } {|error|
                        error.debug("InstrNodeProxy.fx")    
                    }
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

            //this.addSpec("wet%".format(index).asSymbol, [0, 1, \lin, 0, 1].asSpec);
            //this.set("wet%".format(index).asSymbol, wet);
        }
    }

    /*
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
    */

    prNodeInit {

        inserts = Order.new;
        color = Color.rand;
        metadata = ();

        /*
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
                            inserts[index]['ctrl'] = ctrl;
                        }
                    })
                }.defer(2)
            }.defer(1)
        };
        */

        // if we're using a synthdef as a source
        // copy the specs if they are defined
        this.addDependant({|node, what, args|

            //[node, what, args].postln;

            if (what == \source) {
                var obj = args[0];
                var cns, argnames, str;
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
                };

                // create the function that can be used for look up
                // of parameters which can be set, e.g. in a pattern
                // this is modeled after SynthDesc.msgFunc which is used
                // in Event
                cns = node.controlNames;
                argnames = cns.collect({|cn| cn.name }).join(",");
                str = "{|" ++ argnames ++ "|\n";
                str = str ++ "var result = Array.new(%);\n".format(cns.size);
                cns.collect({|cn|
                    str = str ++ "% !? { result.add(\"%\").add(%) };\n".format(cn.name, cn.name, cn.name);
                });
                str = str ++ "result\n";
                str = str + "}";
                msgFunc = str.interpret;
            }
        });

        this.mold(2, \audio);
        this.wakeUp;
        this.vol = 1;
        this.monitor.out = defaultout;

        // initialize or re-initialize
        this.filter(1000, {|in|
            var sig = in;
            sig = Sanitize.ar(sig);
            sig = Splay.ar(
                sig,
                spread: \out_width.kr(1),
                center: \out_pan.kr(0),
                levelComp: false
            ) * \vol.kr(1);
            //sig = Clipper8.ar(sig, -1, 1);// * -6.dbamp;
            // https://scsynth.org/t/install-safety-limiter-plugin-error/6630/2
            //sig = SafetyLimiter.ar(sig);
            sig;
        });

        // don't know what this is doing anymore
        //CmdPeriod.add(cmdperiodfunc);

        // monitor vsts
        skipJack = SkipJack({
            inserts.do({|obj, i|
                if (obj.type == 'vst') {                
                    if (obj.path.notNil) {
                        var ctrl = obj.ctrl;
                        // consider only writing if changes detected?
                        // ctrl.getProgramData({|data| data })
                        //"saving vst state %".format(obj.name).debug(key);
                        ctrl.writeProgram(obj.path);
                    }
                }    
            })
        }, 30);//.start;

        ^this;
    }

    *initClass {
        defaultout = 0;//Server.default.options.numInputBusChannels;

        StartUp.add({
            SynthDef(\instrproxyrecorder1, {
                var buf = \buf.kr(0);
                var bus = \bus.kr(0);
                var sig = In.ar(bus, 2).asArray.sum;
                sig = sig * Env.asr(0.01, 1, 1).ar(gate: 1);
                RecordBuf.ar(sig, buf, loop:0, doneAction:Done.freeSelf);
                Out.ar(0, Silent.ar(2));
            }).add;

            SynthDef(\instrproxyrecorder2, {
                var buf = \buf.kr(0);
                var bus = \bus.kr(0);
                var sig = In.ar(bus, 2);
                sig = sig * Env.asr(0.01, 1, 1).ar(gate: 1);
                RecordBuf.ar(sig, buf, loop:0, doneAction:Done.freeSelf);
                Out.ar(0, Silent.ar(2));
            }).add;
        })

    }
}
