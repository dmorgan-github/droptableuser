N : InstrNodeProxy {
}

InstrNodeProxy : Ndef {

    classvar <>defaultout;
    var <>color;
    var <inserts;
    var <cmdperiodfunc;
    var <msgFunc;
    var <simpleController;
    var skipJack;
    var insertOffset=0;

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

        var offset = insertOffset;
        adverb.debug("InstrNodeProxy adverb");
        
        if (adverb.isNil) {
            "please specify a slot".throw;
        }{
            offset = offset + adverb.asInteger;    
            this.fx(offset, val);
        }; 
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

    mute {|fadeTime=1|
        this.stop(fadeTime:fadeTime)
    }

    unmute {|fadeTime=1|
        this.play(fadeTime:fadeTime)
    }

    view {|cmds|
        ^UiModule('instr').(this, nil, cmds);
    }

    gui {|cmds|
        this.view(cmds).front
    }

    clear {
        this.changed(\clear);
        //skipJack.stop;
        CmdPeriod.remove(cmdperiodfunc);
        inserts.clear;
        simpleController.remove;
        this.releaseDependants;
        Ndef.dictFor(Server.default).envir.removeAt(key);
        this.clearHalo;
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
            });
        }.defer(0.5)
    }

    out_ {|bus=0|
        //TODO: is this the best way to do this?
        var val;
        var outOffset = Server.default.options.numInputBusChannels;
        if (bus.isKindOf(Symbol)) {
            val = bus.asString[1..].asInteger;
            val = (val-1).mod(8);
            val = 2 * val;
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
            if ( path.endsWith(".vstpreset").not) {
                // add extension so it is easier to filter
                path = path ++ ".vstpreset";
            };

            path = path.resolveRelative.debug("path");
            
            // add the vst insert
            node.filter(index, filterfunc);    
            onload = {|ctrl|
                var obj;
                var tempo = 60/TempoClock.default.beatDur;
                ctrl.setTempo(tempo.debug("set tempo"));
                obj = (name:vst, type:'vst', 'ctrl':ctrl, path:path, view:{ ctrl.editor });
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
            var insert = this.inserts[index];
            this.removeAt(index);
            this.inserts.removeAt(index);
            if (insert['path'].notNil) {
                File.delete(insert['path']);
            };
        }{
            var specs;
            if (fx.isFunction) {
                var obj = (name:"func_%".format(UniqueID.next), type:'func');
                obj['ui'] = {|self|
                    UiModule('instr').gui(this, index);
                };
                this.filter(index, fx );
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
                        //cb.(mod);

                        mod.set(\node, this);
                        func = mod.func;
                        this.filter(index, func);
                        this.inserts.put(index, obj);

                    } {|error|
                        error.debug("InstrNodeProxy.fx")    
                    }
                };
            };

            // TODO: is this still necessary
            /*
            if (specs.isNil or: {specs.isEmpty}) {
                {
                    specs = this.objects[index].specs;
                    if (specs.isNil.not) {
                        this.addSpec(*specs.getPairs);
                    };
                }.defer(2)
            } {
                this.addSpec(*specs);
            };
            */
        }
    }

    prNodeInit {

        inserts = Order.new;
        color = Color.rand;

        simpleController = SimpleController(this);
        simpleController.put(\source, {|node, what, args|
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

        ^this;
    }

    *initClass {
        defaultout = 0;//Server.default.options.numInputBusChannels;

        StartUp.add({

            /*
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
            */

            /*
            (
            AbstractPlayControl.buildMethods['filter'] = #{ | func, proxy, channelOffset = 0, index |
                var ok, ugen, proxySynthDef;
                if(proxy.isNeutral) {
                    ugen = func.value(Silent.ar);
                    ok = proxy.initBus(ugen.rate, ugen.numChannels + channelOffset);
                    if(ok.not) { Error("NodeProxy input: wrong rate/numChannels").throw }
                };

                proxySynthDef = { | out |
                    var env, ctl = NamedControl.kr("wet" ++ (index ? 0), 1.0);
                    if(proxy.rate === 'audio') {
                        env = ctl * EnvGate(i_level: 0, doneAction:2, curve:\sin);
                        // pass the index as an argument in the wrap function
                        XOut.ar(out, env, SynthDef.wrap(func, nil, [In.ar(out, proxy.numChannels), Ref(index) ]))
                    } {
                        env = ctl * EnvGate(i_level: 0, doneAction:2, curve:\lin);
                        // pass the index as an argument in the wrap function
                        XOut.kr(out, env, SynthDef.wrap(func, nil, [In.kr(out, proxy.numChannels), Ref(index) ]))
                    };
                }.buildForProxy( proxy, channelOffset, index );
                proxySynthDef.allControlNames
                .reject({|cn| [\out, \i_out, \gate, \fadeTime].includes(cn.name) })
                .reject({|cn| cn.name.asString.beginsWith("wet")  })
                .debug("cn")
                .do ({ |it| it.name = "%%".format(it.name, index).asSymbol});
                proxySynthDef
            }
            )
            */
        })

    }
}
