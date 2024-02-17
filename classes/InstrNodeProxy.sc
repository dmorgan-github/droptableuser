N : InstrNodeProxy {
}

InstrNodeProxy : Ndef {

    classvar <>defaultout;
    //classvar count=0;

    var <vstctrls, <>color;
    var <fxchain, <metadata;
    var <cmdperiodfunc;
    var <msgFunc;
    var <patterns;

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
        vstctrls.clear;
        fxchain.clear;
        metadata.clear;
        this.releaseDependants;
        super.clear;
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
            val = switch(bus, 
                {\t2}, 2, 
                {\t3}, 4,
                {\t4}, 6,
                {\t5}, 8,
                {\t6}, 10,
                {\t7}, 12,
                {\t8}, 14,
                {\t9}, 16,
                {\t10}, 18,
                0
            );
        } {
            val = bus;
        };
        val = outOffset + val;
        this.monitor.out = val.debug("out")        
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

    fx {|index, fx, cb, wet=1|

        if (fx.isNil) {
            this.removeAt(index);
            this.fxchain.removeAt(index);
        }{
            var specs;

            if (fx.isFunction) {
                var obj = (name:"func_%".format(UniqueID.next), type:'func');
                obj['ui'] = {|self|
                    UiModule('instr').gui(this, index);
                };
                this.filter(index, fx);
                this.fxchain.put(index, obj);
            }{

                if (fx.asString.beginsWith("vst:")) {

                    var vst;
                    vst = fx.asString.split($:)[1..].join("/").asSymbol;

                    this.vst(index, vst, cb:{|ctrl|

                        var func;
                        var obj = (name:vst, type:'vst', 'ctrl':ctrl, 'params': Order());

                        func = {|ctrl, what, num, val|
                            if (what == \param) {
                                {
                                    obj['params'].put(num.asInteger, val);
                                }.defer
                            }
                        };
                        obj['ui'] = {|self|
                            ctrl.editor;
                        };
                        obj['writeProgram'] = {|self, path|
                            ctrl.writeProgram(Document.current.dir +/+ path);
                        };
                        obj['readProgram'] = {|self, path|
                            ctrl.readProgram(Document.current.dir +/+ path);
                        };

                        ctrl.addDependant(func);
                        vstctrls.put(index, ctrl);
                        cb.(ctrl);
                        this.fxchain.put(index, obj);
                    });
                }{
                    var func, mod, obj;
                    var key = "fx/%".format(fx).asSymbol;
                    mod = Module(key);
                    obj = (name:fx, type:'func', 'ctrl':mod);
                    obj['ui'] = {|self|
                        UiModule('instr').gui(this, index);
                    };
                    cb.(mod);
                    func = mod.func;
                    this.filter(index, func);
                    this.fxchain.put(index, obj);
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

                    var filename;
                    var mod;

                    filename = vst.asString.toLower;//.split($.);
                    filename = "vst/" ++ filename;
                    if (Module.exists(filename)) {
                        filename.debug("module exists");
                        mod = Module(filename);
                        node.filter(index, mod.func);
                    } {
                        filename.debug("module does not exists");
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

    prNodeInit {

        //count = count+1;
        //keyval = "d%".format(count).asSymbol;
        vstctrls = Order.new;
        fxchain = Order.new;
        patterns = List.new;
        color = Color.rand;
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

        CmdPeriod.add(cmdperiodfunc);

        ^this;
    }

    *initClass {
        defaultout = 0;//Server.default.options.numInputBusChannels;
    }
}
