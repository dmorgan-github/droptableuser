
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

MidiInstrProxy : InstrProxy {

    var <notechan=0, <returnbus=0, <midiout;

    *new {|synth|
        ^super.new().prInitSynth(synth);
    }

    source_ {|pattern|

        if (pattern.isKindOf(Array)) {
            pattern = pattern.p
        };

       super.source = pattern;
    }

    prInitSynth {|argSynth|

        var args;// = argSynth.asString.split($:);

        // TODO: refactor
        midiout = MIDIOut.newByName("IAC Driver", "Bus 1");
        midiout.connect;

        args = argSynth.asString.split($,);
        notechan = args[0].asInteger;
        //returnbus = args[1].asInteger;

        /*
        this.node.put(0, {
            var l = returnbus;
            var r = returnbus+1;
            SoundIn.ar([l, r])
        });
        this.out = DNodeProxy.defaultout + returnbus;
        */

        this.set('type', 'midi', 'midicmd', 'noteOn', 'midiout', midiout, 'chan', notechan)
    }
}

VstInstrProxy : InstrProxy {

    // the synth running on the server
    var <vstsynth;
    // the vst controller
    var <vstplugin;
    var <vstpreset;

    *new {
        ^super.new();
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

    on {|note, vel|
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

            this.set('type', 'composite', 'types', [\vst_midi, \vst_set], 'vst', vstplugin, \spread, 1, \pan, 0)

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

InstrProxy : EventPatternProxy {

    classvar <>count=0;
    classvar <>colors;

    var <node, <cmdperiodfunc, <>color;
    var <>isMono=false, <instrument;
    var <isMonitoring, <nodewatcherfunc;
    var <metadata, <controlNames;
    var <synthdef, <pbindproxy;
    var <synthdefmodule, <note;
    var midictrl, keyval;

    *new {
        ^super.new.prInit();
    }

    @ {|val, adverb|
        if (adverb.isNil and: val.isKindOf(Array)) {
            this.set(*val);
        } {
            this.set(adverb, val)
        }
    }

    @@ {|val, adverb|
        if (adverb.notNil) {
            this.node.setOrPut(adverb, val);
        }
    }

    set {|...args|

        var controlKeys = this.node.controlKeys;

        // this is inefficient for a synth with lots of params
        var nodeprops = Array.new(args.size);
        var synthprops = Array.new(args.size);
        var mycontrolnames = controlNames ?? { [] };

        args.pairsDo({|k, v|
            if ( v.isNumber.or(v.isArray) )  {
                if (mycontrolnames.includes(k)) {
                    synthprops = synthprops.add(k).add(v);
                } {
                    if (controlKeys.includes(k)) {
                        nodeprops = nodeprops.add(k).add(v);
                    }
                }
            };
        });

        Server.default.bind({
            node.set(*nodeprops);
            // this will update the settings on already playing synths,
            // otherwise you have to wait until the next event
            node.group.set(*synthprops);
        });

        args.pairsDo({|k, v|
            if (v.isKindOf(Pattern)) {
                pbindproxy.set(k, v);
            } {
                // clear value to allow changing
                // between pattern and number
                // TODO: rethink this
                if (pbindproxy.find(k).notNil) {
                    pbindproxy.set(k, nil);
                };
                super.set(k, v);
            }
        });
    }

    midi {
        if (midictrl.isNil) {
            midictrl = MidiCtrl(this);
        };
        ^midictrl;
    }

    instrument_ {|name|
        this.prInitSynth(name);
    }

    on {|note, vel=127, extra, debug=false|
        this.note.on(note, vel, extra, debug);
        ^this;
    }

    off {|note|
        this.note.off(note);
        ^this;
    }

    fx {|index, fx, cb|
        this.node.fx(index, fx, cb);
        ^this;
    }

    synth {|index, component, module, cb|
        if (component.isNil) {
            this.synthdefmodule.removeAt(index);
        }{
            cb.value(this.synthdefmodule);
            this.synthdefmodule[index] = component -> module;
        }
    }

    clear {
        this.releaseDependants;
        this.clearHalo;
        this.node.clear;
        this.note.clear;
        this.pbindproxy.clear;
        if (this.midictrl.notNil) {
            this.midictrl.disconnect;
            this.midictrl = nil;
        };
        ServerTree.remove(cmdperiodfunc);
        super.clear;
    }

    fxchain {
        ^this.node.fxchain.array
    }

    controlKeys {|except|
        var keys = envir.keys(Array).sort;
        except = except ++ [];
        ^keys.reject({|key|
            except.includes(key)
        })
    }

    view {|cmds|
        // TODO: using topenvironment as a sort of cache
        // but probably can use Halo instead
        ^UiModule('sgui').envir_(topEnvironment).view(this, nil, cmds);
    }

    gui {|cmds|
        this.view(cmds).front
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

    key {
        var val = super.envirKey(topEnvironment);
        if (val.isNil) {
            val = keyval;
        };
		^val
	}

    key_ {|val|
        keyval = val;
        this.node.key = "%_out".format(keyval).asSymbol;
    }

    print {
        var envir, keys, str = "\n";
        var node = this.node;
        envir = this.envir.copy.parent_(nil);
        keys = envir.keys.asArray.sort;

        this.fxchain.do({|obj, i|
            var prefix = "", fxname;
            if (obj.type == \vst) { prefix = "vst:" };
            fxname = obj.name.asString.split($.)[0];
            fxname = fxname.select({|val| val.isAlphaNum}).toLower;
            str = str ++ "~%[%] = 'fx' -> ('".format(this.key, 20 + i) ++ prefix ++ obj.name ++ "': [";
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
        str = str + "(\n~%".format(this.key) + "\n";
        keys.do({|k|
            var v = envir[k];
            var spec = this.getSpec(k);
            var default = if (spec.notNil) {spec.default}{nil};
            if (v != default and: {k != \instrument}) {
                str = str + ("@." ++ k);
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
                str = str + ("@." ++ k);
                str = str + v.asCode + "\n";
            }
        });
        str = str + ")";
        ^str;
    }

    source_ {|pattern|

        var chain;

        if (pattern.notNil) {

            chain = Pchain(

                //Pbind(
                    /*
                    \node_set, Pfunc({|evt|
                        var pairs;
                        var current = evt;
                        current = current.select({|v, k| nodeptrnprops.includes(k) });
                        pairs = current.getPairs;
                        if (pairs.size > 0) {
                          Server.default.bind({
                            node.set(*pairs)
                          });
                        };
                        1
                    }),
                    */
                //),

                pattern,
                pbindproxy,
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
                    Pbind()
                    <> chain
                }
            })
        }
    }

    prInit {

        var synthfunc, me = this;
        keyval = "instr%".format(count).asSymbol;
        if (count > colors.size) {
            color = Color.rand;
        }{
            color = colors.wrapAt(count);
        };
        count = count + 1;
        node = DNodeProxy().key_("%_out".format(keyval).asSymbol);
        node.color = color;

        this.clock = W.clock;
        note = InstrProxyNotePlayer(this);
        synthdefmodule = SynthDefModule();
        synthdefmodule.addDependant({|obj, what, vals|
            var key = me.key;
            //[obj, what, vals].postln;
            fork {
                await {|done|
                    obj.add(key);
                    Server.default.sync;
                    done.value(\ok);
                };
                // re-initialize the synth
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
        pbindproxy = PbindProxy();
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
        ^this
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
            this.set(\instrument, instrument, \spread, 1, \pan, 0);
        }
    }

    *initClass {

        // nice colors;
        colors = List();
        colors.addAll(
          [
              Color(0.80594773292541, 0.4751119852066, 0.32443220615387),
              Color(0.62813115119934, 0.50460469722748, 0.42918348312378),
              Color(0.50277349948883, 0.55445058345795, 0.85384097099304),
              Color(0.60549101829529, 0.63466150760651, 0.86493694782257),
              Color(0.55233793258667, 0.65434362888336, 0.71119487285614),
              Color(0.77472245693207, 0.82329275608063, 0.75887560844421),
              Color(0.67403962612152, 0.74898204803467, 0.83484077453613),
              Color(0.43814084529877, 0.35949912071228, 0.8521347284317),
              Color(0.60353236198425, 0.85716576576233, 0.54857833385468),
              Color(0.84560143947601, 0.71142382621765, 0.53232064247131),
              Color(0.75822179317474, 0.58384845256805, 0.37344696521759),
              Color(0.46127707958221, 0.63891048431396, 0.49481935501099),
              Color(0.7760725736618, 0.79725716114044, 0.52006945610046),
              Color(0.61446368694305, 0.50829205513, 0.49966106414795),
              Color(0.74614992141724, 0.8588672876358, 0.77721869945526),
              Color(0.67358100414276, 0.74493434429169, 0.40996670722961)
          ].scramble
        )
    }
}


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
        var evt = stream.next(Event.default);
        var instrument = instr.instrument;

        evt[\freq] = note.midicps;
        evt[\vel] = (vel/127).squared;
        evt[\gate] = 1;

        if (extra.notNil) {
            evt = evt ++ extra;
        };

        args = evt.use({
            ~amp = ~amp.value;
            SynthDescLib.global[instrument].msgFunc.valueEnvir
        });

        if (debug) {
            args.postln;
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





