
/*
sequencable/modulatable from midi/osc
sequencable/modulatable from patterns
composable with patterns
modulatable from bus
viewable/modulatable with gui
savable
playable with synthdef, vst, midi instruments
filterable with sc fx
filterable with vst fx
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
        this.out = DMNodeProxy.defaultout + returnbus;
        */

        MidiCtrl.connect(device, {|obj|
            midiout = obj['out'];
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

    on {|note, vel=1|
        vstplugin.midi.noteOn(0, note, vel)
    }

    off {|note|
        vstplugin.midi.noteOff(0, note)
    }

    savePresetAs {|name|
        var path = Module.libraryDir +/+ "preset" +/+ name;
        vstplugin.writeProgram(path);
    }

    writeProgram {|path|
        var dir = Document.current.dir;
        path = dir +/+ path;
        vstplugin.writeProgram(path)
    }

    readProgram {|path|
        var dir = Document.current.dir;
        path = dir +/+ path;
        vstplugin.readProgram(path)
    }

    prInitSynth {|argSynth|

        {
            var plugin;
            var args;

            args = argSynth.asString.split($/);
            plugin = args[0];
            if (args.size > 1){
                vstpreset = args[1];
                vstpreset = Module.libraryDir +/+ "preset" +/+ vstpreset;
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

            this.set('type', 'composite', 'types', [\vst_midi, \vst_set], 'vst', vstplugin)

        }.fork;
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
    var note, <msgFunc;
    var <key, <synthdefmodule;
    var specs;
    var <ptrns, <groupprops;

    *new {|key|
        ^super.new.prInit(key);
    }

    @ {|val, adverb|
        if (adverb.isNil and: val.isKindOf(Array)) {
            this.set(*val);
        } {
            //if (val.isFunction) {
            //    var key = "%_%_lfo".format(this.key, adverb).asSymbol.debug("lfo");
            //    val = Ndef(key)[0] = val;
            //};
            this.set(adverb, val)
        }
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
        this.ptrns.put(num, pattern);
        this.source = pattern;
    }

    set {|...args|

        var evt, nodeprops=[], synthprops=[];
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

    clear {
        this.changed(\clear);
        node.clear;
        note.clear;
        //pbindproxy.clear;
        ServerTree.remove(cmdperiodfunc);
        this.releaseDependants;
        super.clear;
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

    out_ {|bus|
        this.node.monitor.out = bus
    }

    view {|cmds|
        // TODO: using topenvironment as a sort of cache 
        ^UiModule('instr').envir_(topEnvironment).view(this, nil, cmds);
    }

    gui {|cmds|
        this.view(cmds)
        .front
    }

    printOn {|stream|
		super.printOn(stream);
		stream << " key:" << this.key << " out:" << this.out
	}

    print {
        var envir, keys, str = "\n";
        var node = this.node;
        envir = this.envir.copy.parent_(nil);
        keys = envir.keys.asArray.sort;

        node.fxchain.array.do({|obj, i|
            var prefix = "", fxname;
            if (obj.type == \vst) { prefix = "vst:" };
            fxname = obj.name.asString.split($.)[0];
            fxname = fxname.select({|val| val.isAlphaNum}).toLower;
            str = str ++ "~%.fx(%, '".format(this.key, 20 + i) ++ prefix ++ obj.name ++ "')";
            if (obj.params.notNil) {
                var names = obj.ctrl.info.parameters;
                //str = str ++ "~%.fxchain[%].ctrl.set(*[".format(this.key, i);
                obj.params.array.do({|val, i|
                    if (i > 0) {str = str + ","};
                    str = str ++ "'" ++ names[i].name ++ "', " ++ val.asCode;
                });
                str = str ++ "]);\n";
            };
            str = str + "\n\n";
        });

        str = str + "\n";
        str = str ++ "(\n~%".format(this.key) + "\n";
        keys.do({|k|
            var v = envir[k];
            var spec = this.getSpec(k);
            var default = if (spec.notNil) {spec.default}{nil};
            if (v != default and: {  [\instrument, \bufposreplyid, \buf].includes(k).not }) {
                str = str ++ ("@." ++ k);
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
                str = str ++ ("@." ++ k);
                str = str + v.asCode + "\n";
            }
        });
        str = str ++ ")";
        ^str;
    }

    source_ {|pattern|

        var chain;
        if (pattern.notNil) {

            chain = Pchain(
                Pbind(
                    \node_set, Pfunc({|evt|
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
                        1
                    })
                ),
                pattern,
                //pbindproxy,
                Plazy({
                    Pbind(
                        \out, Pfunc({node.bus.index}),
                        \group, Pfunc({node.group.nodeID}),
                    )
                })
            );

            super.source = Plazy({
                instrument = instrument ?? {\default};
                if (isMono) {
                    // not sure how to make composite event work with pmono
                    Pmono(instrument, \trig, 1) <> chain
                }{
                    chain
                }
            })
        }
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

        instrument = synthname;
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

            if (metadata['gatemode'] == \retrig) {
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
        node = DMNodeProxy("%_out".format(key).asSymbol);

        specs = ();
        ptrns = Order();
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

// InstrProxyNotePlayer {{{
InstrProxyNotePlayer {

    var <synths;
    var <instr;
    var <stream;
    var <synthdef;

    *new {|instrproxy|
        ^super.new.prInit(instrproxy);
    }

    clear {
        synths.clear;
    }

    on {|note, vel=127, extra, debug=false|
        var args;
        var target = instr.node.group.nodeID;
        var instrument, evt;
        var velocity = (vel/127).squared;
        var freq;
        evt = instr.envir.copy.parent_(Event.default);
        evt['vel'] = velocity;
        evt['midinote'] = note;
        evt['out'] = instr.node.bus.index;
        // TODO: perhaps this can be an option
        //evt = stream.next( evt );
        instrument = instr.instrument;

        evt[\gate] = 1;
        if (extra.notNil) {
            evt = evt ++ extra;
        };

        args = evt.use({
            ~freq = ~freq.value;
            ~amp = ~amp.value;
            ~sustain = ~sustain.value;
            ~dur = ~dur.value;
            ~stretch = ~stretch.value;

            instr.msgFunc.valueEnvir
        });

        if (debug) {
            args.asCompileString.postln;
        };

        if (instr.synthdef.hasGate) {

            if (synths[note].isNil) {
                synths[note] = Synth(instrument, args, target:target, addAction:\addToHead);
            }
        } {
            Synth(instrument, args, target:target, addAction:\addToHead);
        }    
    }

    off {|note|
        if (instr.synthdef.hasGate) {
            synths.removeAt(note).set(\gate, 0)
        }
    }

    prInit {|instrproxy|
        instr = instrproxy;
        stream = instr.asStream;
        synthdef = instr.synthdef;
        synths = Order.new;
    }
}
// }}}

// InstrProxyBuilder {{{
InstrProxyBuilder {

    classvar <fx;
    classvar <sig, <fil;

    var <synthdefmodule;
    var <proxy;   
    var current, currentargs;
    var num = 0, fxnum = 20;

    *new {|instrproxy, key|
        ^super.new.prInit(instrproxy, key)
    }

    value {|func|
        var mod;
        mod = Module(func);
        // TODO: this needs to work with any role
        this.prAddModule('sig', mod);
        ^this;
    }

    // TODO: relying on this is not particularly robust
    doesNotUnderstand {|selector ...args|
        var mod, key; 
        //selector.debug("selector");
        if (synthdefmodule.modules.size == 0) {
            if (sig[selector].notNil) {
                mod = Module(sig[selector])
            } {
                key = "synth/%".format(selector).asSymbol;
                mod = Module(key);
            };
            this.prAddModule('sig', mod, args);
        } {
            current.add(selector);
            currentargs.add(args);
        };
        ^this;
    }

    + {|module|
        var id = current.pop;
        var args = currentargs.pop;
        var mod;
        if (sig[id].notNil) {
            mod = Module(sig[id])
        } {
            var key = "synth/%".format(id).asSymbol;
            mod = Module(key);
        };
        this.prAddModule('sig', mod, args);
        ^this;
    }

    * {|module|
        var id = current.pop;
        var args = currentargs.pop;
        var key = "env/%".format(id).asSymbol;
        var mod = Module(key);
        this.prAddModule('env', mod, args);
        ^this;
    }

    > {|module|
        var id = current.pop;
        var args = currentargs.pop;
        var mod;
        if (fil[id].notNil) {
            mod = Module(fil[id])
        } {
            var key = "filter/%".format(id).asSymbol;
            mod = Module(key);
        };
        this.prAddModule('fil', mod, args);
        ^this;
    }

    | {|module|
        var id, key, func, args;
        id = current.pop;
        args = currentargs.pop;
        func = fx[id];
        proxy.node.fx(fxnum, func);
        args.debug("node args");
        fxnum = fxnum + 1;
        ^this;
    }

    prAddModule {|role, mod, args|
        if (args.notNil) {
            mod.set(*args)//debug("args")
        };
        synthdefmodule.put(num, role -> mod);
        num = num + 1;
    }

    prInit {|instrproxy, key|
        current = List();
        currentargs = List();
        proxy = instrproxy ?? InstrProxy(key);
        synthdefmodule = proxy.synthdefmodule;
        synthdefmodule.modules.clear;
    }

    *initClass {
        fx = Dictionary();
        fx['del'] = 'delay/fb';
        fx['rev'] = 'reverb/miverb';
        fx['ps'] = 'granular/pitchshift';
        fx['compress'] = 'dynamics/hardkneecompressor';
        fx['spiralstretch'] = 'vst:++spiralstretch.vst3';
        fx['bubbler'] = 'vst:++bubbler.vst3';
        fx['lofi'] = 'vst:CHOWTapeModel.vst3';

        sig = Dictionary();
        fil = Dictionary();
    }
}
// }}}



