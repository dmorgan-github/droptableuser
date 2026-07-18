
// MidiInstrProxy {{{
MidiInstrProxy : InstrProxy {

    var <>notechan=0, <returnbus=0, <midiout;
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
        //[notechan, note, vel].debug("on");
        midiout.noteOn(notechan, note, vel)
    }

    off {|note|
        //[notechan, note].debug("off");
        midiout.noteOff(notechan, note)
    }

    bend {|val=8192|
        //val.debug("VstInstrProxy");
        midiout.bend(notechan, val: val)    
    }

    prInitMidiSynth {|device chan|
        this.envir = ();
        //this.ctlNumMapping = ();
        notechan = chan;
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

    // -12 to 12
    bend {|val=8192|
        //val.debug("VstInstrProxy");
        vstplugin.midi.bend(0, val: val)
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

        instrument = argSynth;

        fork({

            var plugin;
            var args;
            var synthname = 'vsti';

            args = argSynth.asString.split($/);
            plugin = args[0];
            // if (args.size > 1){
            //     preset_path = args[1].asString;
            // } {
            //     preset_path = key.asString.select({|val| val.isAlphaNum});
            // };

            // if ( preset_path.endsWith(".vstpreset").not) {
            //     // add extension so it is easier to filter
            //     preset_path = preset_path ++ ".vstpreset";
            // };
            // preset_path = preset_path.resolveRelative;//.debug("preset_path");

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
                if (false /*preset_path.notNil*/) {
                    if (File.exists(preset_path)) {
                        preset_path.debug("VstInstrProxy");
                        ctrl.readProgram(preset_path)
                    }
                }
            });

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
            SynthDef(\vsti, {|out| 
                Out.ar(out, VSTPlugin.ar(Silent.ar(2), 2) * \amp.kr(-20.dbamp)) 
            }).add;
        });
    }
}
// }}}

TaskInstrProxy : Tdef {

    *new { |key, item|
        item.debug("item");
		^super.new(key, item).prInit;
	}

    prInit {
        
    }
}

InstrProxyLfo {

    var <instrProxy;
    var <all;

    *new {|proxy|
		^super.new.prInit(proxy)
	}

    put {|prop ...pairs|
        var mod = all.at(prop);
        if (mod.isNil) {
            var key = "%/%".format(instrProxy.key, prop).asSymbol;
            mod = M('device/wtlfo').(key);
            all.put(prop, mod);
        };
        instrProxy.set(prop, mod);
        if (pairs.notNil and: { pairs.size > 0} ) {
            mod.set(*pairs);
        };
        ^mod
    }

    at {|prop|
        ^all.at(prop);        
    }

    clear {
        "clear".debug("InstrProxyLfo");
        all.do({|v| v.free });
        all.clear;
    }

    prInit {|proxy|
        instrProxy = proxy;
        all = IdentityDictionary();
        instrProxy.addUniqueMethod(\modulate, {|self, prop ...pairs|
            var mod = all.at(prop);
            if (mod.isNil) {
                var key = "%/%".format(instrProxy.key, prop).asSymbol;
                mod = M('device/wtlfo').(key);
                all.put(prop, mod);
            };
            instrProxy.set(prop, mod);
            if (pairs.notNil and: { pairs.size > 0} ) {
                mod.set(*pairs);
            };
            mod
        });

        ^this;  
    }
}

// InstrProxy {{{
InstrProxy : EventPatternProxy {

    classvar <count=0;
    classvar <>colors;

    var <node, <cmdperiodfunc, <>color;
    var <>isMono=false, <>hasgate=true, <instrument;
    var <isMonitoring;
    var <controlNames;
    var <synthdef;
    var <>notePlayer, <msgFunc;
    var <key;
    var <simpleController;
    var <synthbuilder;
    var <data;
    //var <stuff;
    var <lfos;
    var playFunc, stopFunc;
    var viewFunc;

    //var specs;
    var protoEvent;

    *new {|key|
        ^super.new.prInit(key);
    }

    printOn {|stream|
        super.printOn(stream);
        stream << " key:" << this.key << " out:" << this.out
    }

    // synth
    <+ {|val|
        synthbuilder.build(val);
    }

    +> {|val, adverb|
        var index = adverb.asInteger;
        this.fx[index] = val;
    }

    // props
    @ {|val, adverb|

        if (val.isKindOf(Function)) {
            var key = "%_%".format(this.key, adverb).asSymbol.debug("lfo");
            var ndef = lfos.at(key);
            if (ndef.isNil) {
                ndef = Ndef(key, val).quant_(1.0);
            };
            ndef[0] = val;
            lfos.put(adverb, ndef);
            val = ndef;
        };
        this.set(adverb, val)
    }

    // lfos
    // @> {|val, adverb|

        
    //     if (ndef.isNil) {
    //         if (val.isKindOf(Function)) {
    //             ndef = Ndef(key, val)
    //         }
    //     };
    //     if (val.isKindOf(Function)) {
    //         ndef[0] = val
    //     };
    //     lfos.put(adverb, ndef);
    //     this.set(adverb, ndef);

    //     // if (val == 'view') {
    //     //     ^lfo.at(adverb).view.front
    //     // } {
    //     //     lfo.put(adverb, *val);
    //     // }
    // }

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

    fx {
        ^this.node;
    }

    proto {
        ^protoEvent;
    }

    proto_ {|val|
        protoEvent = val.debug("InstrProxy:proto");
        super.set(\proto, protoEvent);
    }

    /*
    map {|key, val|

        if (val.isKindOf(Function)) {
            var mykey = "%_%_lfo".format(this.key, key).asSymbol;
            val = Ndef(mykey, val).quant_(1)
        };
        "map % %".format(key, val).debug("InstrProxy");
        this.set(key, val);
    }
    */

    /*
    unmap {|key|
        // no-op - overridenn in child class    
    }
    */

    set {|...args|

        var evt, nodeprops=[], synthprops=[];

        // does this impact performance?
        if (args[0].isArray) {
            args = args.flatten;
        };

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

    bend {|val=8192|
        var bendmid = 8192;
        var bendmin = -12;
        var bendmax = 12;
        val = val.linlin(0, bendmid * 2, bendmin, bendmax);
        this.set(\bend, val)    
    }

    play_ {|val|
        playFunc = val    
    }

    play {|doReset=false, fadeTime=0, quant|

        if (playFunc.isNil) {
            if (fadeTime > 0) {
                // node stop will force the output proxy to be freed and a new one created
                // when play is invoked - not sure this is a great way to do this
                node.stop(fadeTime:0).play(fadeTime:fadeTime);
            } {
                if (node.isMonitoring.not ) {
                    node.play;
                };
            };
            super.play(protoEvent:protoEvent, doReset:doReset);

        }{
            playFunc.(doReset, fadeTime, quant)
        }
    }

    stop_ {|val|
        stopFunc = val;    
    }

    stop {|fadeTime=0|
        if (stopFunc.isNil) {

            if (fadeTime > 0) {
                node.stop(fadeTime:fadeTime);
                {
                    super.stop
                }.defer( fadeTime + 0.5 )
            } {
                super.stop
            }

        }{
            stopFunc.(fadeTime)
        }
    }

    clear {
        this.changed(\clear);
        "node.clear".debug("InstrProxy");
        simpleController.remove;
        node.clear;
        notePlayer.clear;
        //specs.clear;
        envir.clear;
        ServerTree.remove(cmdperiodfunc);
        this.releaseDependants;
        //stuff.clear;
        lfos.keys.do({|k| 
            lfos.at(k).free
        });
        lfos.clear;

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

    view_{|val|
        viewFunc = val;    
    }

    view {|cmds|
        //^UiModule('instr').(this, nil, cmds);
        ^viewFunc.(this, nil, cmds)
    }

    gui {|cmds|
        this.view(cmds).front
    }

    stringify {
        
        var kv, str;
        kv = this.envir.copy.parent_(nil).proto_(nil)
        .reject({|v, k| ['vst', 'type', 'types', 'instrument', 'bufposreplyid', 'buf', 'kb_toggle' ].includes(k) })
        //.reject({|v, k| v.isKindOf(NodeProxy) })
        .reject({|v|
            var test = v.isNumber or: { v.isString } or: { v.isCollection } or: { v.isKindOf(Symbol) };
            test.not
        })
        .reject({|v, k|
            var spec = this.getSpec[k];
            var default = if (spec.notNil) {spec.default}{nil};
            v == default
        });

        str = kv.asPairs.asCompileString;

        ^str;
    }

    source_ {|pattern|

        var chain, ptrn;
        if (pattern.isKindOf(Function)) {
            ptrn = pattern
        } {
            pattern = pattern ?? { Pbind() };
            chain = Pchain(
                pattern,
                Plazy({
                    Pbind(
                        \out, node.bus.index,
                        \group, Pfunc( { node.group.nodeID }),
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
        };
        
        super.source = ptrn
    }

    /*
    getSpec {
        ^specs;
    }
    */

    /*
    addSpec {|...pairs|
        if (pairs.notNil) {
            pairs.pairsDo { |name, spec|
                if (spec.notNil) { spec = spec.asSpec };
                specs.put(name, spec)
            }
        };
    }
    */


    prInitSynth {|synthname|

        instrument = synthname ?? { \default };
        synthdef = SynthDescLib.global.at(instrument);

        if (synthdef.isNil) {
            //"synth does not exist".debug(synth)
        } {

            var metadata;

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

        key = argKey;
        if (key.isNil) { key = "instr%".format(count).asSymbol };
        color = colors.wrapAt(count);
        //specs = ();
        node = InstrNodeProxy("%/node".format(key).asSymbol);
        node.color = color;

        notePlayer = InstrProxyNotePlayer(this);
        synthbuilder = InstrProxySynthBuilder(this);
        data = InstrProxyPersistance(this);
        //stuff = IdentityDictionary(know:true);
        //lfo = InstrProxyLfo(this);
        lfos = IdentityDictionary(know:true);
        viewFunc = UiModule('instr');

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

        ^this
    }

    *initClass {
        colors = List();
    }
}
// }}}







