N : InstrNodeProxy {
}

// InstrFx : Order {

//     var <node;

//     *new {|node|
// 		^super.new.clear(8).prInit(node)
// 	}

//     vst {|index, vst, obj|

//         var mykey = node.key ?? "n%".format(node.identityHash.abs);
//         var vstkey = vst.asString.select({|val| val.isAlphaNum});
//         var nodekey = mykey.asString.replace("/", "_");
//         var key = "%_%".format(nodekey, vstkey).toLower.asSymbol;
//         var nodeId, ctrl;
//         var oscfunc, onload;

//         var server = Server.default;
//         var path, split;
//         var now = SystemClock.seconds;
//         var filterfunc = {|in| VSTPlugin.ar(in, 2, info:vst);};

//         split = vst.asString.split($/);
//         vst = split[0].asSymbol;
//         path = split[1];//.asString.debug("path1");
//         if (path.isNil ) {
//             path = key.asString;
//         } {
//             path = path.asString;   
//         };
//         if ( path.endsWith(".vstpreset").not) {
//             // add extension so it is easier to filter
//             path = path ++ ".vstpreset";
//         };

//         //path = path.resolveRelative.debug("path");
//         path = "%%".format(PathName(thisProcess.nowExecutingPath()).pathOnly, path);

//         obj['name'] = vst;
//         obj['type'] = 'vst';
//         obj['path'] = path;
        
//         // add the vst insert
//         node.filter(index, filterfunc);    
//         onload = {|ctrl|

//             var tempo = 60/TempoClock.default.beatDur;
//             ctrl.setTempo(tempo.debug("set tempo"));

//             obj['ctrl'] = ctrl;
//             obj['view'] = {ctrl.editor};
//             obj['save'] = {|self| 
//                 ctrl.writeProgram(self.path.debug("writeProgram")) 
//             };
//             obj['load'] = {|self, path|
//                 ctrl.readProgram(path.debug("readProgram")); 
//                 self.path = path;   
//             };

//             if (File.exists(path)) {
//                 ctrl.readProgram(path.debug("readProgram"));
//             };
//         };

//         // wire up with plugin controller
//         oscfunc = {
//             nodeId = node.objects[index].nodeID;
//             ctrl = if (node.objects[index].class == SynthDefControl) {
//                 var synthdef = node.objects[index].synthDef;
//                 var synth = Synth.basicNew(synthdef.name, server, nodeId);    
//                 VSTPluginController(synth, synthDef:synthdef);
//             }{
//                 var synth = Synth.basicNew(vst, server, nodeId);
//                 VSTPluginController(synth);
//             };

//             ctrl.open(vst, editor:true, verbose: true, action:{|ctrl|
//                 "loaded %".format(key).postln;
//                 onload.(ctrl);
//             });
//         };

//         // adapted from: https://scsynth.org/t/jitlib-how-to-know-if-a-nodeproxy-is-fully-ready/9941?u=droptableuser
//         OSCFunc({
//             (SystemClock.seconds - now).debug("seconds to open synth");
//             oscfunc.();
//         }, '/n_go', server.addr, argTemplate: [node.objects[index].nodeID] ).oneShot;
//     }

//     loadFx {|index, fx|

//         var obj = ();
//         obj['delete'] = {
//             node.removeAt(index);
//             this.removeAt(index)
//         };

//         obj['set2'] = {|self ...args|
//             node.set(*args)
//         };

//         if (fx.isFunction) {
//             obj['name'] = "func_%".format(UniqueID.next);
//             obj['type'] = 'func';
//             obj['view'] = {|self|
//                 UiModule('instr').gui(this, index);
//             };
//             node.filter(index, fx);
//         } {

//             if (fx.asString.beginsWith("vst:")) {
//                 var vst = fx.asString.split($:)[1..].join("/").asSymbol;
//                 this.vst(index, vst, obj);
//             }{

//                 var func, mod, key;
//                 try {
//                     if (fx.isKindOf(Module)) {
//                         mod = fx;
//                         key = mod.key;
//                     };
                    
//                     obj['name'] = key;
//                     obj['type'] = 'func';
//                     obj['ctrl'] = mod;
//                     obj['view'] = {|self|
//                         var ui = 'instr';
//                         if (mod.view.notNil) {
//                             ui = mod.view;
//                         };
//                         UiModule(ui).gui(node, index);
//                     };
//                     mod.set(\node, node);
//                     func = mod.func;
//                     node.filter(index, func);
//                 } {|error|
//                     error.debug("InstrNodeProxy.fx")    
//                 }
//             };
//         };

//         obj['stringify'] = {|self|
//             var keys;
//             keys = node
//             .objects[index]
//             .controlNames
//             .reject({|cn| ['out', 'fadeTime', 'levelreplyid', 'bufposreplyid', 'gate'].includes(cn.name) })
//             .refject({|cn| cn.name.asString.beginsWith("wet") })
//             .collect({|cn| 
//                 var key = cn.name;
//                 var val = t(8).node.get(key);
//                 [key, val]
//             })
//             .flatten
//             .asCompileString
//         };

//         obj['save'] = {|self|
//             var path, str;
//             var name = self['name'];
//             str = self.stringify;
//             path = "%_%_%.scd".format(node.key, index, name).replace("/", "_");
//             path = path.resolveRelative.debug("save");
//             File.use(path, "w", { |f|
//                 f.write(str);
//             });
//         };

//         ^obj;
//     }

//     put {|index, obj|
//         var fx = this.loadFx(index, obj);
//         super.put(index, fx)    
//     }

//     prInit {|argNode|
//         node = argNode;
//         ^this
//     }
// }

InstrNodeProxy : Ndef {

    classvar <>defaultout;
    var <>color;
    // var <fx;
    var <cmdperiodfunc;
    var <msgFunc;
    var <simpleController;

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
        CmdPeriod.remove(cmdperiodfunc);
        // fx.clear;
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

    loadVst {|index, vst, obj|

        var mykey = this.key ?? "n%".format(this.identityHash.abs);
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

        //path = path.resolveRelative.debug("path");
        path = "%%".format(PathName(thisProcess.nowExecutingPath()).pathOnly, path);

        // obj['name'] = vst;
        // obj['type'] = 'vst';
        // obj['path'] = path;
        
        // add the vst insert
        super.put(index, \filter -> filterfunc);    
        onload = {|ctrl|

            var lfos = IdentityDictionary();
            var tempo = (60/TempoClock.default.beatDur);//TempoClock.default.tempo;
            ctrl.setTempo(tempo.debug("set tempo"));
            ctrl.addUniqueMethod('lfos', { lfos });
            ctrl.addUniqueMethod(\map2, {|self, prop, func|  
                var lfokey = "%_%_lfo".format(key, prop).asSymbol.debug("InstrNodeProxy.loadVst");
                var ndef = Ndef(lfokey, func).quant_(1.0);
                lfos.put(prop, ndef);
                self.map(prop, ndef);
            });
            this[index].addUniqueMethod(\ctrl, { ctrl } );

            // obj['ctrl'] = ctrl;
            // obj['view'] = {ctrl.editor};
            // obj['save'] = {|self| 
            //     ctrl.writeProgram(self.path.debug("writeProgram")) 
            // };
            // obj['load'] = {|self, path|
            //     ctrl.readProgram(path.debug("readProgram")); 
            //     self.path = path;   
            // };

            if (File.exists(path)) {
                ctrl.readProgram(path.debug("readProgram"));
            };
        };

        // wire up with plugin controller
        oscfunc = {
            nodeId = this.objects[index].nodeID;
            ctrl = if (this.objects[index].class == SynthDefControl) {
                var synthdef = this.objects[index].synthDef;
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
        }, '/n_go', server.addr, argTemplate: [this.objects[index].nodeID] ).oneShot;
    }

    // loadFx {|index, fx|

    //     // var obj = ();
    //     // obj['delete'] = {
    //     //     node.removeAt(index);
    //     //     this.removeAt(index)
    //     // };

    //     // obj['set2'] = {|self ...args|
    //     //     node.set(*args)
    //     // };

    //     if (fx.isFunction) {
    //         // obj['name'] = "func_%".format(UniqueID.next);
    //         // obj['type'] = 'func';
    //         // obj['view'] = {|self|
    //         //     UiModule('instr').gui(this, index);
    //         // };
    //         super.put(index, \filter -> fx);
    //     } {

    //         if (fx.asString.beginsWith("vst:")) {
    //             var vst = fx.asString.split($:)[1..].join("/").asSymbol;
    //             this.vst(index, vst, obj);
    //         }{

    //             var func, mod, key;
    //             try {
    //                 if (fx.isKindOf(Module)) {
    //                     mod = fx;
    //                     key = mod.key;
    //                 };
                    
    //                 // obj['name'] = key;
    //                 // obj['type'] = 'func';
    //                 // obj['ctrl'] = mod;
    //                 // obj['view'] = {|self|
    //                 //     var ui = 'instr';
    //                 //     if (mod.view.notNil) {
    //                 //         ui = mod.view;
    //                 //     };
    //                 //     UiModule(ui).gui(node, index);
    //                 // };
    //                 mod.set(\node, this);
    //                 func = mod.func;
    //                 super.put(index, \filter -> func);
    //             } {|error|
    //                 error.debug("InstrNodeProxy.fx")    
    //             }
    //         };
    //     };

    //     // obj['stringify'] = {|self|
    //     //     var keys;
    //     //     keys = node
    //     //     .objects[index]
    //     //     .controlNames
    //     //     .reject({|cn| ['out', 'fadeTime', 'levelreplyid', 'bufposreplyid', 'gate'].includes(cn.name) })
    //     //     .refject({|cn| cn.name.asString.beginsWith("wet") })
    //     //     .collect({|cn| 
    //     //         var key = cn.name;
    //     //         var val = t(8).node.get(key);
    //     //         [key, val]
    //     //     })
    //     //     .flatten
    //     //     .asCompileString
    //     // };

    //     // obj['save'] = {|self|
    //     //     var path, str;
    //     //     var name = self['name'];
    //     //     str = self.stringify;
    //     //     path = "%_%_%.scd".format(node.key, index, name).replace("/", "_");
    //     //     path = path.resolveRelative.debug("save");
    //     //     File.use(path, "w", { |f|
    //     //         f.write(str);
    //     //     });
    //     // };

    //     // ^obj;
    // }

    put {|index, obj, channelOffset = 0, extraArgs, now = true|

        if ( obj.asString.beginsWith("vst:")  ) {
            var vst = obj.asString.split($:)[1..].join("/").asSymbol;
            this.loadVst(index, vst, obj);
        } {
            if (obj.isKindOf(Module)) {
                obj.set(\node, this);
                super.put(index, \filter -> obj.func);
            } {
                super.put(index, obj, channelOffset, extraArgs, now);
            }
        }

        // {
        //     this.specs
        //     .keysValuesDo({|key, value|
        //         this.addSpec(key, value)
        //     });
        // }.defer(0.5)
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

    // getSpec {
    //     ^this.specs;
    // }

    // addSpec {|...pairs|
    //     if (pairs.notNil) {
	// 		pairs.pairsDo { |name, spec|
	// 			if (spec.notNil) { spec = spec.asSpec };
    //             this.specs.put(name, spec)
	// 		}
	// 	};
    // }

    prNodeInit {

        // fx = InstrFx(this);//Order.new;
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
            //sig = Sanitize.ar(sig);
            sig = Splay.ar(
                sig,
                spread: \out_width.kr(1),
                center: \out_pan.kr(0),
                levelComp: false
            ) * \volume.kr(1);
            //sig = Clipper8.ar(sig, -1, 1);// * -6.dbamp;
            // https://scsynth.org/t/install-safety-limiter-plugin-error/6630/2
            //sig = SafetyLimiter.ar(sig);
            sig;
        });

        ^this;
    }

    *initClass {
        defaultout = 0;//Server.default.options.numInputBusChannels;

        //StartUp.add({

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
        //})

    }
}
