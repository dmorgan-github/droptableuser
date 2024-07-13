
/*
x sequencable/modulatable from midi/osc
x sequencable/modulatable from patterns
x composable with patterns
x modulatable from bus
x viewable/modulatable with gui
savable
x playable with synthdef, vst, midi instruments
x filterable with sc fx
x filterable with vst fx
*/

// MidiInstrProxy {{{
MidiInstrProxy : InstrProxy {

    var <notechan=0, <returnbus=0, <midiout;

    *new {|device, chan|
        ^super.new().prInitMidiSynth(device, chan);
    }

    source_ {|pattern|

        if (pattern.isKindOf(Array)) {
            pattern = pattern.p
        };

       super.source = pattern;
    }

    instrument_ {
        "Not Implemented".throw
    }

    on {|note, vel=1|
        midiout.noteOn(notechan, note, vel)
    }

    off {|note|
        midiout.noteOff(notechan, note)
    }

    prInitMidiSynth {|device notechan|

        //var args;// = argSynth.asString.split($:);

        // TODO: refactor
        //midiout = MIDIOut.newByName("IAC Driver", "Bus 1");
        //midiout.connect;

        //args = argSynth.asString.split($,);
        //notechan = args[0].asInteger;
        //returnbus = args[1].asInteger;

        /*
        this.node.put(0, {
            var l = returnbus;
            var r = returnbus+1;
            SoundIn.ar([l, r])
        });
        this.out = InstrNodeProxy.defaultout + returnbus;
        */

        MidiCtrl.connect(device, cb:{|obj|
            midiout = obj.out;
            this.set('type', 'midi', 'midicmd', 'noteOn', 'midiout', midiout, 'chan', notechan)
        });
    }
}
// }}}

// VstInstrProxy {{{
VstInstrProxy : InstrProxy {

    // the synth running on the server
    var <vstsynth;
    // the vst controller
    var <vstplugin;
    var <vstpreset;

    *new {|key|
        ^super.new(key);
    }

    source_ {|pattern|

        var src;

        if (pattern.isKindOf(Array)) {
            pattern = pattern.p
        };

        src = Pchain(
            pattern
        );

        super.source = src;
    }

    gui {
        vstplugin.editor;
    }

    on {|note, vel=127|
        vstplugin.midi.noteOn(0, note, vel)
    }

    off {|note|
        vstplugin.midi.noteOff(0, note)
    }

    find {|str|
        var params = this.vstplugin.info.parameters;
        var vals = params.select({|p| p.name.asString.contains(str) });
        var result = List();
        vals.do({|v|
            var index = params.detectIndex({|p, i| p.name.asString.contains(v.name.asString) });
            var parm = params[index];
            result.add([index, parm]);
        });
        ^result.asArray
    }

    savePreset {|name|
        var path = Module.libraryDir +/+ "preset" +/+ name;
        vstplugin.writeProgram(path);
    }

    loadPreset {|name|
        var path = Module.libraryDir +/+ "preset" +/+ name;
        vstplugin.readProgram(path)
    }

    writeProgram {|filename|
        //var dir = Document.current.dir;
        //path = dir +/+ path;
        //vstplugin.writeProgram(path)
        var dir = PathName(thisProcess.nowExecutingPath).pathOnly;
        var path = dir +/+ filename;
        vstplugin.writeProgram(path)
    }

    readProgram {|filename|
        //var dir = Document.current.dir;
        //path = dir +/+ path;
        //vstplugin.readProgram(path)
        var dir = PathName(thisProcess.nowExecutingPath).pathOnly;
        var path = dir +/+ filename;
        vstplugin.readProgram(path)
    }

    prInitSynth {|argSynth|

        fork({

            var plugin;
            var args;

            args = argSynth.asString.split($/);
            plugin = args[0];
            if (args.size > 1){
                var path, dir;
                dir = PathName(thisProcess.nowExecutingPath).pathOnly;
                vstpreset = args[1];

                path = dir ++ vstpreset;
                if (File.exists(path).not) {
                    path = Module.libraryDir +/+ "preset" +/+ vstpreset;
                };

                if (File.exists(path)) {
                    vstpreset = path;
                } {
                    "preset does not exist: %".format(vstpreset).warn
                }
                
            };
            synthdef = SynthDescLib.global[\vsti].def;

            vstsynth = Synth(\vsti,
                args: [\out, this.node.bus.index],
                target: this.node.group.nodeID
            );

            // i can't find a better way, sync doesn't help in this scenario
            //1.wait;
            Server.default.latency.wait;
            vstplugin = VSTPluginController(vstsynth, synthDef:synthdef);
            vstplugin.open(plugin, editor: true, verbose:true, action:{|ctrl|
                if (vstpreset.notNil) {
                    vstpreset.debug("preset");
                    ctrl.readProgram(vstpreset)
                }
            });

            // need to specify which params will be modulated
            // \params, [\Mix, \Depth, 1]
            this.set('type', 'composite', 'types', [\vst_midi, \vst_set], 'vst', vstplugin)

        });
    }

    clear {
        this.vstplugin.close;
        this.vstsynth.free;
        super.clear;
    }

    *initClass {
        StartUp.add({
            SynthDef(\vsti, { |out| Out.ar(out, VSTPlugin.ar(Silent.ar(2), 2)) }).add;
        });
    }
}
// }}}

// InstrProxy {{{
InstrProxy : EventPatternProxy {

    classvar <>count=0;
    classvar <>colors;

    var <node, <cmdperiodfunc, <>color;
    var <>isMono=false, <instrument;
    var <isMonitoring, <nodewatcherfunc;
    var <metadata, <controlNames;
    var <synthdef;
    var <note, <msgFunc;
    var <key, <synthdefmodule;
    var specs;

    *new {|key|
        ^super.new.prInit(key);
    }

    doesNotUnderstand {|selector ...args|

        var key = selector.asGetter.asString;
        var module = args[0];
        var result, index = 0;

        result = key.findRegexp("^(fx)([0-9]*)$");
        if (result.size > 0) {
            index = if (result[2].size > 1) { result[2][1].asInteger };
            index = 20 + index;

            if (module.isKindOf(Module)) {
                //module = module.func;
            }{
                if (module.isKindOf(Function)) {
                    //module = Module(module)
                    // pass function
                } {
                    module = module.asSymbol;
                }
            };
            this.fx(index, module);
        };

        /*
        if (observer.evaluate(key, args).not) {
            //var updateSource = false;
            // TODO: deprecate this probably
            if (args[0].isKindOf(Pattern) or: {args[0].isKindOf(Routine)} ) {
                this.set(key, nil);
                patterns.put(key, args[0]);
                updateSource = true;
            } {
                var val = args[0];
                if (patterns[key].notNil) {
                    patterns[key] = nil;
                    updateSource = true;
                };
                this.set(key, val);
            };
            if (updateSource) {
                this.source = Pbind(*patterns.asKeyValuePairs);
            }
        };
        */
        ^this;
    }

    // synth
    s {|...args|
        var observer = InstrProxyObserver(this);
        args.flatten.keysValuesDo({|k, v|
            observer.evaluate(k, [v])
        })
    }

    // pattern
    p {|...args|

        if (args[0].isKindOf(Pattern)) {
            this.source = args[0];
        } {
            var a;
            var vals = args;
            if (vals[0].isArray) {
                vals = vals[0]
            };
            vals.pairsDo({|k, v|
                a = a.add(k).add(v);     
            });
            this.source = Pbind(*a);
        }

        /*
        if (args[0].isArray) {
            var a;
            var pattern = args[0];
            pattern.pairsDo {|k,v|
                a = a.add(k).add(v);
            };
            pattern = Pbind(*a);
        } {
            if args[0].isKindOf(Pattern) {
                this.source = pattern;
            } {
                var a;
                args.pairsDo {|k, v|
                    a = a.add(k).add(v);    
                }    
            }
        }
            */
        //if (adverb.notNil) {
        //    num = adverb.asInteger;
        //};
        //this.ptrns.put(num, pattern);
        //patterns.clear;
        
    }

    // data
    d {|...args|
        this.set(*args)    
    }

    << {|pattern, adverb|
        var num = 0;
        if (pattern.isArray) {
            var a;
            pattern.pairsDo {|k,v|
                a = a.add(k).add(v);
            };
            pattern = Pbind(*a);
        };
        if (adverb.notNil) {
            num = adverb.asInteger;
        };
        //this.ptrns.put(num, pattern);
        //patterns.clear;
        this.source = pattern;
    }

    set {|...args|

        var evt, nodeprops=[], synthprops=[];
        args = args.flatten;
        evt = args.asEvent;

        nodeprops = evt.use({ node.msgFunc.valueEnvir });
        synthprops = evt.use({ this.msgFunc.valueEnvir });

        if (nodeprops.size > 0) {
            var val = Array.new(nodeprops.size);
            nodeprops.keysValuesDo({|k, v|
                if (v.isNumber.or(v.isArray).or(v.isKindOf(NodeProxy)) ) {
                    val = val.add(k.asSymbol).add(v);
                } {
                    if (v.isNil) {
                        node.set(k, nil)
                    };
                }
            });
            if (val.size > 0) {
                node.set(*val)
            };
        };

        if (synthprops.size > 0) {
            var val = Array.new(synthprops.size);
            synthprops.keysValuesDo({|k, v|
                if (v.isNumber.or(v.isArray).or(v.isKindOf(NodeProxy))) {
                    val.add(k.asSymbol).add(v);
                } {
                    if (v.isNil) {
                        //node.group.set(k, nil)
                        node.setGroup([k, nil])
                    }
                }
            });
            if (val.size > 0) {
                //node.group.set(*synthprops)
                node.setGroup(synthprops)
            }
        };

        args.pairsDo({|k, v|
            super.set(k, v);
        });
    }

    instrument_ {|name|
        this.prInitSynth(name);
    }

    on {|midinote=60, vel=127, extra, debug=false|
        note.on(midinote, vel, extra, debug);
        ^this;
    }

    off {|midinote=60|
        note.off(midinote);
        ^this;
    }

    fx {|index, fx, cb|
        this.node.fx(index, fx, cb);
        ^this;
    }

    play {|argClock, protoEvent, quant, doReset=false, fadeTime=0|
        if (fadeTime > 0) {
            // node stop will force the output proxy to be freed and a new one created
            // when play is invoked - not sure this is a great way to do this
            node.stop(fadeTime:0).play(fadeTime:fadeTime);
        } {
            if (node.isMonitoring.not ) {
                node.play;
            };
        };
        super.play(argClock, protoEvent, quant, doReset)  ;
    }

    stop {|fadeTime=0|
        if (fadeTime > 0) {
            node.stop(fadeTime:fadeTime);
            {
                super.stop
            }.defer( fadeTime + 0.5 )
        } {
            super.stop
        }
    }

    clear {
        this.changed(\clear);
        "node.clear".debug("InstrProxy");
        node.clear;
        "note.clear".debug("InstrProxy");
        note.clear;
        "specs.clear".debug("InstrProxy");
        specs.clear;
        "envir.clear".debug("InstrProxy");
        envir.clear;
        "metadata.clear".debug("InstrProxy");
        metadata.clear;
        "remove cmdperiodfunc".debug("InstrProxy");
        ServerTree.remove(cmdperiodfunc);
        "releaseDependants".debug("InstrProxy");
        this.releaseDependants;
        "super.clear".debug("InstrProxy");
        super.clear;
        ^nil
    }

    controlKeys {|except|
        var keys = envir.keys(Array).sort;
        except = except ++ [];
        ^keys.reject({|key|
            except.includes(key)
        })
    }

    kill {|ids|
        ids.asArray.do({|id|
            Synth.basicNew(this.instrument, Server.default, id).free
        });
    }

    mute {|fadeTime=1|
        this.node.stop(fadeTime:fadeTime)
    }

    unmute {|fadeTime=1|
        this.node.play(fadeTime:fadeTime)
    }

    out {
        ^this.node.monitor.out
    }

    out_ {|bus=0|
        this.node.out = bus;
    }

    view {|cmds|
        // TODO: using topenvironment as a sort of cache
        //cmds = cmds ?? { "[(freq fx) props]" };
        ^UiModule('instr').envir_(topEnvironment).view(this, nil, cmds);
    }

    gui {|cmds|
        this.view(cmds).front
    }

    printOn {|stream|
		super.printOn(stream);
		stream << " key:" << this.key << " out:" << this.out
	}

    stringify {
        var envir, keys, str = "\n";
        var node = this.node;
        envir = this.envir.copy.parent_(nil);
        keys = envir.keys.asArray.sort;

        node.fxchain.do({|obj, index|
            var prefix = "", fxname;
            var i = index - 20;
            if (obj.type == \vst) { prefix = "vst:" };
            fxname = obj.name.asString.split($.)[0];
            fxname = fxname.select({|val| val.isAlphaNum}).toLower;
            str = str ++ "fx%: '".format(i) ++ prefix ++ obj.name ++ "'";
            if (obj.params.notNil) {
                var names = obj.ctrl.info.parameters;
                //str = str ++ "~%.fxchain[%].ctrl.set(*[".format(this.key, i);
                obj.params.array.do({|val, i|
                    if (i > 0) {str = str + ","};
                    str = str ++ "'" ++ names[i].name ++ "', " ++ val.asCode;
                });
                str = str ++ "]);\n";
            };
            str = str + "\n";
        });

        //str = str + "\n";
        //str = str ++ "(\n~%".format(this.key) + "\n";
        keys.do({|k|
            var v = envir[k];
            var spec = this.getSpec[k];
            var default = if (spec.notNil) {spec.default}{nil};
            //[default, v, k, spec.default].debug("equal");
            if (v != default and: {  [\instrument, \bufposreplyid, \buf].includes(k).not }) {
                //str = str ++ ("@." ++ k);
                str = str ++ k ++ ":";
                str = str + v.asCode + "\n";
            }
        });

        envir = node.nodeMap;
        keys = envir.keys.asArray.sort;
        keys.do({|k|
            var v = envir[k];
            var spec = node.getSpec(k);
            var default = if (spec.notNil) {spec.default}{nil};
            if (v != default and: { [\i_out, \out, \fadeTime].includes(k).not } ) {
                //str = str ++ ("@." ++ k);
                str = str ++ k ++ ":";
                str = str + v.asCode + "\n";
            }
        });
        //str = str ++ ")";
        ^str;
    }

    clipboard {
        var str = this.stringify;
        "echo \"%\" | /usr/bin/pbcopy".format(str).unixCmd;
        "copied to clipboard".postln;
    }

    source_ {|pattern|

        var chain;
        pattern = pattern ?? {Pbind()};
        chain = Pchain(
            /*
            Pbind(
                \node_set, Pfunc({|evt|
                    if (evt.isRest) {
                        // no-op
                    } {
                        var args = evt.use({
                            node.msgFunc.valueEnvir;
                        });
                        if (evt[\node_set_debug].notNil) {
                            args.postln;
                        };
                        if (args.size > 0) {
                            Server.default.bind({
                                node.set(*args)
                            })
                        };
                    };
                    1
                })
            ),
            */
            pattern,
            //pbindproxy,
            //Plazy({
                Pbind(
                    \out, Pfunc({node.bus.index}),
                    \group, Pfunc({node.group.nodeID}),
                    /*
                    \phase, Prout({|inval|
                        inf.do({|i|
                            var len = inval['phaselen'] ?? {inf};
                            var offset = inval['phaseoffset'] ?? {0};
                            var phase = i.mod(len) + offset;
                            inval = phase.embedInStream(inval);
                        })
                    }),
                    \dur, Pfunc({|evt|
                        var val = evt['dur'] ?? 1;
                        val.value
                    })
                    */
                )
            //})
        );

        super.source = //Plazy({
            if (isMono) {
                // not sure how to make composite event work with pmono
                Pmono(instrument) <> chain <> Pbind(\trig, 1)
                //Pmonophonic() <> chain <> Pbind(\trig, 1)
            }{
                chain
            }
        //})
    }

    getSpec {
        ^specs;
    }

    addSpec {|...pairs|
        if (pairs.notNil) {
			pairs.pairsDo { |name, spec|
				if (spec.notNil) { spec = spec.asSpec };
                specs.put(name, spec)
			}
		};
    }

    prInitSynth {|synthname|

        instrument = synthname ?? { \default };
        synthdef = SynthDescLib.global.at(instrument);

        if (synthdef.isNil) {
            //"synth does not exist".debug(synth)
        } {

            synthdef
            .controls.reject({|cn|
                [\freq, \pitch, \trigger, \trig,
                    \in, \buf, \gate, \glis,
                    \bend, \out, \vel].includes(cn.name.asSymbol)
            }).do({|cn|
                var key = cn.name.asSymbol;
                var spec = Spec.specs[key];
                if (spec.notNil) {
                    this.addSpec(key, spec);
                }
            });

            metadata = synthdef.metadata ?? ();
            if (metadata[\specs].notNil) {
                metadata[\specs].keysValuesDo({|k, v|
                    this.addSpec(k, v);
                })
            };

            if (metadata['voices'] == \mono) {
                this.isMono = true;
            };

            //"set defaults from spec...".debug("ssynth");
            if (this.getSpec.notNil) {
                this.getSpec.keys.do({|key|
                    var spec = this.getSpec[key];
                    if (this.get(key).isNil) {
                        this.set(key, spec.default);
                    }
                });
            };

            controlNames = SynthDescLib.global.at(instrument).controlNames;
            this.set(\instrument, instrument);
        }
    }

    prInit {|argKey|

        var synthfunc, me = this;
        //keyval = "instr%".format(count).asSymbol;
        key = argKey;
        if (key.isNil) {
            key = "instr%".format(count).asSymbol;
        };

        if (count > colors.size) {
            color = Color.rand;
        }{
            color = colors.wrapAt(count);
        };
        count = count + 1;
        node = InstrNodeProxy("%/node".format(key).asSymbol);

        specs = ();
        //ptrns = Order();
        //patterns = ();
        note = InstrProxyNotePlayer(this);
        synthdefmodule = SynthDefModule();

        // TODO would like to simplify this
        synthdefmodule.addDependant({|obj, what, vals|
            //[obj, what, vals].postln;

            fork {
                obj.add(key);
                Server.default.sync;
                // re-initialize the synth
                msgFunc = SynthDescLib.global[key].msgFunc;
                me.instrument = key;
                me.metadata.putAll(obj.metadata);
            };
        });

        nodewatcherfunc = {|obj, what|
            if ((what == \play) or: (what == \stop)) {
                isMonitoring = obj.isMonitoring
            }
        };
        node.addDependant(nodewatcherfunc);

        node.play;
        super.source = Pbind();

        cmdperiodfunc = {
            {
                node.wakeUp;
                if (isMonitoring) {
                    node.play
                };
            }.defer(0.5)
        };

        node.color = color;
        ServerTree.add(cmdperiodfunc);
        ^this
    }

    *initClass {
        colors = List();
    }
}
// }}}







