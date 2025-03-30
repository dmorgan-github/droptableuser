
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
    var <>ctlNumMapping;

    *new {|device, chan|
        ^super.new().prInitMidiSynth(device, chan);
    }

    @ {|val, adverb|
        this.set(adverb, val)
    }

    set {|...args|
        var ctlNum;

        if (args[0].isArray) {
            args = args.flatten;
        };

        args.pairsDo({|k, v|
            //super.set(k, v);
            this.envir.put(k, v);
            if (this.ctlNumMapping.notNil ) {
                ctlNum = this.ctlNumMapping[k];
                if (ctlNum.notNil ) {
                    this.midiout.control(0, ctlNum: ctlNum, val: v)
                }; 
            }
        }); 

        this.changed(\set, args);
    }

    returnbus_ {|val|
        val = val.asArray;
        this.node.put(0, {
            var l = val.wrapAt(0);
            var r = val.wrapAt(1);
            SoundIn.ar([l, r])
        });
    }

    source_ {|pattern|

        if (pattern.isKindOf(Array)) {
            pattern = pattern.p
        };

       super.source = pattern;
    }

    instrument_ {|val|
        var path = "synth/%".format(val.toLower);
        if (M.exists(path)) {

            var module = M(path);
            if (module.notNil) {
                var mapping = module.value;
                ctlNumMapping = mapping;
                ctlNumMapping.keysValuesDo({|k, v|
                    var spec = ControlSpec(0, 127, \lin, 1, 0);
                    this.addSpec(k, spec);
                    this.envir.put(k, 0);
                });
            }
        } {
            "module does not exist: %".format(path).inform
        }
    }

    on {|note, vel=1|

        [notechan, note, vel].debug("on");
        midiout.noteOn(notechan, note, vel)
    }

    off {|note|
        [notechan, note].debug("off");
        midiout.noteOff(notechan, note)
    }

    prInitMidiSynth {|device notechan|
        this.envir = ();
        //this.ctlNumMapping = ();
        MidiCtrl.connect(device, cb:{|obj|
            midiout = obj.out;
            midiout.latency = 0;
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
    var <preset_path;

    *new {|key|
        ^super.new(key);//.initVstSynth;
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

    on {|note, vel=127, extra|
        vstplugin.midi.noteOn(0, note, vel);
        this.changed(\noteOn, [note, vel, extra]);
    }

    off {|note|
        vstplugin.midi.noteOff(0, note);
        this.changed(\noteOff, [note]);
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

    discover {
        
        var ctrl = this.vstplugin;
        var params = ctrl.info.parameters;
        var vals = Dictionary();
        var rout;
        
        rout = Routine({
        
            4.do({
                params.do({|v|
                    var name = v['name'];
                    ctrl.get(name, action:{|f|
                        var val = vals[name];
                        if (val.isNil) {
                            vals.put(name, f);  
                        } {
                            if (val != f) {
                                name.postln;
                            }
                        }
                    })   
                });
                4.wait;
            })
        });
        rout.play;
    }

    map {|key, val|

        if (val.isKindOf(Function)) {
            val = Ndef("%_%_lfo".format(this.key, key))[0] = val;
        };
        this.vstplugin.map(key, val)
    }

    unmap {|key|
        this.vstplugin.unmap(key)    
    }

    prInitSynth {|argSynth|

        fork({

            var plugin;
            var args;
            var synthname = 'vsti';

            args = argSynth.asString.split($/);
            plugin = args[0];
            if (args.size > 1){
                preset_path = args[1].asString;
            } {
                preset_path = key.asString.select({|val| val.isAlphaNum});
            };

            if ( preset_path.endsWith(".vstpreset").not) {
                // add extension so it is easier to filter
                preset_path = preset_path ++ ".vstpreset";
            };
            preset_path = preset_path.resolveRelative.debug("preset_path");

            if (SynthDescLib.global[plugin.asSymbol].notNil) {
                synthname = plugin.asSymbol.debug("synthdef");
            };
            synthdef = SynthDescLib.global[synthname].def;

            vstsynth = Synth(synthname,
                args: [\out, this.node.bus.index],
                target: this.node.group.nodeID
            );

            // 
            msgFunc = SynthDescLib.global[synthname].msgFunc;

            // i can't find a better way, sync doesn't help in this scenario
            //1.wait;
            Server.default.latency.wait;
            vstplugin = VSTPluginController(vstsynth, synthDef:synthdef);
            vstplugin.open(plugin, editor: true, verbose:true, action:{|ctrl|
                if (preset_path.notNil) {
                    if (File.exists(preset_path)) {
                        preset_path.debug("VstInstrProxy");
                        ctrl.readProgram(preset_path)
                    }
                }
            });

            this.set('type', 'composite', 'types', [\vst_midi, \vst_set], 'vst', vstplugin)
            //this.set('type', 'vst_midi', 'vst', vstplugin)

        });
    }

    clear {
        this.vstplugin.close;
        this.vstsynth.free;
        super.clear;
    }

    save {
        vstplugin.writeProgram(preset_path);      
    }

    *initClass {
        StartUp.add({
            SynthDef(\vsti, {|out| 
                Out.ar(out, VSTPlugin.ar(Silent.ar(2), 2) * \amp.kr(-20.dbamp)) 
            }).add;
        });
    }
}
// }}}

// InstrProxy {{{
InstrProxy : EventPatternProxy {

    classvar <count=0;
    classvar <>colors;

    var <node, <cmdperiodfunc, <>color;
    var <>isMono=false, <>hasgate=true, <instrument;
    var <isMonitoring;
    var <metadata, <controlNames;
    var <synthdef;
    var <>notePlayer, <msgFunc;
    var <key, <synthdefmodule;
    var <simpleController;
    var <lfos;
    var <>data_path;
    var <skipJack;
    var <>autosave=true;

    var specs;
    var protoEvent;
    var insertOffset=0;

    *new {|key|
        ^super.new.prInit(key);
    }

    // synth
    <+ {|val|

        //if (synthdefmodule.notNil) {
        //    synthdefmodule.envir.clear;
        // SynthDefModule();
        //};
        synthdefmodule = SynthDefModule();
        synthdefmodule.evaluate(val);

        fork {
            synthdefmodule.add(key);
            Server.default.sync;
            // re-initialize the synth
            this.instrument = key;
        };
    }

    // fx inserts
    +> {|val, adverb|

        var offset = insertOffset;
        if (adverb.isNil) {
            "please specify a slot".throw;
        }{
            offset = offset + adverb.asInteger;    
        }; 
        this.node.fx(offset, val);
    }

    inserts {
        ^this.node.inserts;//.at(insertOffset + index) 
    }

    removeInsert {|index|
        this.node.fx(insertOffset + index, nil)    
    }

    // props
    @ {|val, adverb|

        if (adverb.isNil and: val.isKindOf(Array)) {
            this.set(*val);
        } {
            this.set(adverb, val)
        }
    }

    @@ {|val, adverb|
        this.map(adverb, val)    
    }

    // set fx props
    // TODO: not sure about this
    % {|val, adverb|

        if (val.isKindOf(Lfo)) {
            var mykey = "%_%_lfo".format(this.key, adverb).asSymbol;
            var nodes = val.value(mykey).first;
            lfos.put(mykey, nodes);
            this.node.set(adverb, nodes);
            {
                nodes.do({|n|
                    n.parentGroup = this.node.group    
                });
            }.defer(5)
        } {
            this.node.set(adverb, val);    
        }
    }

    // pattern
    << {|pattern, adverb|
        
        if (pattern.isArray) {
            var a;
            pattern.pairsDo {|k,v|
                a = a.add(k).add(v);
            };
            pattern = Pbind(*a);
        };

        this.source = pattern;           
    }

    proto {
        ^protoEvent;
    }

    proto_ {|val|
        protoEvent = val.debug("InstrProxy:proto");
        super.set(\proto, protoEvent);
    }

    map {|key, val|
    
        if (val.isKindOf(Function)) {
            val = Ndef("%_%_lfo".format(this.key, key))[0] = val;
        };
        this.set(key, val);
    }

    unmap {|key|
        // no-op - overridenn in child class    
    }

    set {|...args|

        var evt, nodeprops=[], synthprops=[];

        // does this impact performance?
        if (args[0].isArray) {
            args = args.flatten;
        };

        //if (args[0].isKindOf(Environment)) {
        //    evt = args[0];
        //}{
            evt = args.asEvent;
        //};
        
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
                    val = val.add(k.asSymbol).add(v);
                } {
                    if (v.isNil) {
                        //node.group.set(k, nil)
                        node.setGroup([k, nil])
                    }
                }
            });
            if (val.size > 0) {
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

    on {|midinote=60, vel=127, extra|
        notePlayer.on(midinote, vel, extra);
        this.changed(\noteOn, [midinote, vel, extra]);
        ^this;
    }

    off {|midinote=60|
        notePlayer.off(midinote);
        this.changed(\noteOff, [midinote]);
        ^this;
    }

    play {|doReset=false, fadeTime=0, quant|
        if (fadeTime > 0) {
            // node stop will force the output proxy to be freed and a new one created
            // when play is invoked - not sure this is a great way to do this
            node.stop(fadeTime:0).play(fadeTime:fadeTime);
        } {
            if (node.isMonitoring.not ) {
                node.play;
            };
        };
        super.play(protoEvent:protoEvent, doReset:doReset)  ;
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
        skipJack.stop;
        "node.clear".debug("InstrProxy");
        simpleController.remove;
        node.clear;
        notePlayer.clear;
        specs.clear;
        envir.clear;
        metadata.clear;
        ServerTree.remove(cmdperiodfunc);
        this.releaseDependants;
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
        ^this.node.out
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
        
        var kv, str;
        kv = this.envir.copy.parent_(nil).proto_(nil)
        .reject({|v, k| ['vst', 'type', 'types', 'instrument', 'bufposreplyid', 'buf' ].includes(k) })
        .reject({|v, k| v.isKindOf(NodeProxy) })
        .reject({|v, k|
            var spec = this.getSpec[k];
            var default = if (spec.notNil) {spec.default}{nil};
            v == default
        });

        str = kv.asCompileString;

        ^str;
    }

    source_ {|pattern|

        var chain, ptrn;
        pattern = pattern ?? { Pbind() };
        chain = Pchain(
            pattern,
            Plazy({
                Pbind(
                    \out, node.bus.index,
                    \group, node.group.nodeID,
                    \sendGate, this.hasgate
                )
            })
        );

        ptrn = Plazy({
            if (isMono) { 
                Pmono(instrument) <> chain <> Pbind(\trig, 1) 
            }{ 
                chain 
            }    
        });

        super.source = ptrn
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

    save {
        // to be overridden
        //"save".debug("InstrProxy");
    }

    prSave {
        var str = this.stringify;
        if (str.size > 0) {
            File.use(this.data_path, "w", { |f|
                f.write(str)
            })
        }
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
                    \in, \buf, \gate, \glide,
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

            this.isMono = false;
            if (metadata['voices'] == \mono) {
                this.isMono = true;
            };

            this.hasgate = synthdef.hasGate;
            //if (metadata['hasgate'] == false) {
            //    this.hasgate = false;
            //};

            //"set defaults from spec...".debug("ssynth");
            if (this.getSpec.notNil) {
                this.getSpec.keys.do({|key|
                    var spec = this.getSpec[key];
                    if (this.get(key).isNil) {
                        this.set(key, spec.default);
                    }
                });
            };

            msgFunc = synthdef.msgFunc;
            controlNames = synthdef.controlNames;
            this.set(\instrument, instrument);
        }
    }

    prInit {|argKey|

        var synthfunc;

        key = argKey;
        if (key.isNil) { key = "instr%".format(count).asSymbol };
        color = colors.wrapAt(count);
        specs = ();
        lfos = Dictionary();
        node = InstrNodeProxy("%/node".format(key).asSymbol);
        node.color = color;
        data_path = "%%_data.scd".format( PathName(thisProcess.nowExecutingPath).pathOnly, key.asString.select({|val| val.isAlphaNum})).debug("data_path");

        notePlayer = InstrProxyNotePlayer(this);
        //synthdefmodule = SynthDefModule();

        simpleController = SimpleController(node);
        simpleController.put(\play, {|model, what, data| isMonitoring = model.isMonitoring });
        simpleController.put(\stop, {|model, what, data| isMonitoring = model.isMonitoring });

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

        ServerTree.add(cmdperiodfunc);
        count = count + 1;

        skipJack = SkipJack({
            if (this.autosave) {
                this.prSave;
                this.save;
            }
        }, 30);

        

        ^this
    }

    *initClass {
        colors = List();
    }
}
// }}}







