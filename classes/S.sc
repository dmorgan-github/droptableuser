/*
Synth
*/

/*
nice colors:
Color(0.60549101829529, 0.63466150760651, 0.86493694782257, 0.2)
Color(0.55233793258667, 0.65434362888336, 0.71119487285614, 0.2)
Color(0.77472245693207, 0.82329275608063, 0.75887560844421, 0.2)
Color(0.67403962612152, 0.74898204803467, 0.83484077453613, 0.2)
Color(0.43814084529877, 0.35949912071228, 0.8521347284317, 0.2)
Color(0.60353236198425, 0.85716576576233, 0.54857833385468, 0.2)
Color(0.84560143947601, 0.71142382621765, 0.53232064247131, 0.2)
Color(0.75822179317474, 0.58384845256805, 0.37344696521759, 0.2)
Color(0.46127707958221, 0.63891048431396, 0.49481935501099, 0.2)
Color(0.7760725736618, 0.79725716114044, 0.52006945610046, 0.2)
Color(0.61446368694305, 0.50829205513, 0.49966106414795, 0.2)
Color(0.68937842845917, 0.80199530124664, 0.8592972278595, 0.2)
Color(0.74614992141724, 0.8588672876358, 0.77721869945526, 0.2)
Color(0.67358100414276, 0.74493434429169, 0.40996670722961, 0.2)
Color(0.66662492752075, 0.72109272480011, 0.70863604545593, 0.2)
*/
S {

    *synth {|key, synth|

        var envir = currentEnvironment;
        var res = envir[key];

        if (res.isNil){

            if (synth.notNil) {
                var src = synth.asString;
                res = case
                {src.beginsWith("vst:")} {
                    SVstSynth(src.asSymbol).key_(key)
                }
                {src.beginsWith("midi:")} {
                    SMidiSynth(src.asSymbol).key_(key)
                }
                {
                    SSynth(src.asSymbol).key_(key)
                };
                envir[key] = res;
            } {
                "source not provided".warn
            }
        } {
            if (synth.notNil) {
                res.synth = synth;
            }
        };

        ^res;
    }

    *clear {|key|
        var envir = currentEnvironment;
        var res = envir[key];
        if (res.notNil) {
            envir.removeAt(key);
            res.clear;
        }
    }

    *initClass {
    }
}

// TODO: this hasn't been tested
SMidiSynth : SSynth {

    var <notechan=0, <returnbus=0, <midiout;

    *new {|synth|
        ^super.new(synth);
    }

    source_ {|pattern|

        var src;

        if (pattern.isKindOf(Array)) {
            pattern = pattern.p
        };

        src = Pchain(
            Pbind(
                \type, \midi,
                \midicmd, \noteOn,
                \midiout, Pfunc({midiout}),
                \chan, Pfunc({notechan})
            ),
            pattern
        );

        super.source = src;
    }

    prInitSynth {|argSynth|

        var args = argSynth.asString.split($:);

        // TODO: refactor
        midiout = MIDIOut.newByName("IAC Driver", "Bus 1");
        midiout.connect;

        args = args[1].split($,);
        notechan = args[0].asInteger;
        returnbus = args[1].asInteger;
        this.node.put(0, {
            var l = returnbus;
            var r = returnbus+1;
            SoundIn.ar([l, r])
        });
        this.out = DNodeProxy.defaultout + returnbus;
    }
}

SVstSynth : SSynth {

    var <vstsynthdef=\vsti;
    var <vstsynth, <vstplugin, <vstpreset;

    *new {|synth|
        ^super.new(synth);
    }

    source_ {|pattern|

        var src;

        if (pattern.isKindOf(Array)) {
            pattern = pattern.p
        };

        src = Pchain(
            Pbind(
                \vst_set, Pfunc({|evt|
                    // TODO server.bind
                    Server.default.makeBundle(Server.default.latency, {
                        var current = evt;
                        //var vstcontrols = SynthDescLib.global[vstsynthdef].controlNames;
                        var args = current['vstparams'] ?? [];//vstcontrols.reject({|n| n == \out});
                        current = current.select({|v, k| args.includes(k) and: {v > 0} });
                        //current.postln;
                        if (current.size > 0) {
                            vstplugin.set(*current.getPairs)
                        }
                    });
                    1
                })
            ),
            pattern
        );

        super.source = src;
    }

    gui {
        vstplugin.editor;
    }

    on {|note, vel=127, debug|
        vstplugin.midi.noteOn(0, note, vel)
    }

    off {|note|
        vstplugin.midi.noteOff(0, note)
    }

    savePreset {|name|
        var path = App.librarydir +/+ "preset" +/+ name;
        vstplugin.writeProgram(path);
    }

    prInitSynth {|argSynth|

        {
            var plugin;
            var args = argSynth.asString.split($:);
            args = args[1].split($/);
            plugin = args[0];
            if (args.size > 1){
                vstpreset = args[1];
                vstpreset = App.librarydir +/+ "preset" +/+ vstpreset;
            };
            synthdef = SynthDescLib.global[vstsynthdef].def;

            vstsynth = Synth(vstsynthdef,
                args: [\out, this.node.bus.index],
                target: this.node.group.nodeID
            );
            1.wait;
            vstplugin = VSTPluginController(vstsynth, synthDef:synthdef);
            vstplugin.open(plugin, editor: true, verbose:true, action:{|ctrl|
                if (vstpreset.notNil) {
                    vstpreset.debug("preset");
                    ctrl.readProgram(vstpreset)
                }
            });
            this.set('type', 'vst_midi', 'vst', vstplugin, \spread, 1, \pan, 0, \amp, -6.dbamp);

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

SSynth : EventPatternProxy {

    classvar count=0;

    var <node, <cmdperiodfunc, <>color;
    var <>isMono=false, <synth;
    var <isMonitoring, <nodewatcherfunc;
    var <metadata, <controlNames;
    var <synths, <synthdef;
    var keyval;

    *new {|synth|
        ^super.new.prInit.prInitSynth(synth);
    }

    @ {|val, adverb|

        if (adverb.isNil and: val.isKindOf(Array)) {
            this.set(*val);
        } {
            var func = Fdef("dialects/%".format(adverb).asSymbol);
            if (func.source.isNil) {
                this.set(adverb, val);
            }{
                func.(val, this);
            }
        }
    }

    set {|...args|

        var controlKeys = this.node.controlKeys;

        // TODO server.bind
        Server.default.makeBundle(Server.default.latency, {
            var dict = args.asDict;
            var val = dict.select({|v, k| controlKeys.includes(k) });
            node.set(*val.getPairs);

            // this will update the settings on already playing
            // synths, otherwise you have to wait until the next
            // event
            if (controlNames.notNil) {
                val = dict.select({|v, k| controlNames.includes(k) });
                node.group.set(*val.getPairs);
            }
        });

        super.set(*args);
    }

    patternAt {|index, pattern|

        var key = "%_%_set".format(this.key, index).asSymbol;

        if (pattern.isNil) {
            Pdef(key).stop;
            Pdef(key).clear;
        }{
            Pdef(key,
                pattern
                <>
                Pbind(
                    \type, \set,
                    \id, synths[index].nodeID
                )
            ).play
        };
    }

    synth_ {|synthname|
        this.prInitSynth(synthname);
    }

    fx {|index, fx, wet=1|
        if (index.isArray) {
            index.do({|fx, i|
                var slot = 100 + i;
                this.node.fx(slot, fx, wet);
            })
        }{
            this.node.fx(index, fx, wet);
        }

    }

    clear {
        this.node.free;
        this.node.clear;
        this.synths.clear;
        super.clear;
    }

    fxchain {
        ^this.node.fxchain
    }

    controlKeys {|except|
        var keys = envir.keys(Array).sort;
        except = except ++ [];
        ^keys.reject({|key|
            except.includes(key)
        })
    }

    view {
        ^Ui('sgui').envir_(topEnvironment).view(this);
    }

    gui {
        this.view.front
    }

    savePreset {|name|
        var v, f;
        var e = this.envir.copy.parent_(nil);
        e.removeAt('instrument');
        v = e.getPairs;
        f = App.librarydir ++ "preset/%".format(name);
        f = File.open(f, "w");
        f.write(v.asCode);
        f.close();
    }

    kill {|ids|
        ids.asArray.do({|id|
            Synth.basicNew(this.synth, Server.default, id).free
        });
    }

    out {
        ^this.node.monitor.out
    }

    out_ {|bus|
        this.node.monitor.out = bus
    }

    key_ {|val|
        keyval = val;
        node.key = "%_out".format(val).asSymbol;
    }

    key {
        ^keyval;
    }

    on {|note, vel=127, extra, debug=false|

        var evt = this.envir ?? ();
        var args;
        var out = this.node.bus.index;
        var target = this.node.group;

        if (extra.notNil) {
            extra = extra.asDict;
            evt = evt ++ extra;
        };

        args = [\out, out, \gate, 1, \freq, note.midicps, \vel, (vel/127).squared]
        ++ evt
        .reject({|v, k|
            (v.isNumber.not and: v.isArray.not and: {v.isKindOf(BusPlug).not})
        })
        .asPairs();

        if (debug) {
            args.postln;
        };

        if (synthdef.hasGate) {
            if (synths[note].isNil) {
                synths[note] = Synth(synth, args, target:target, addAction:\addToHead);
            }
        } {
            Synth(synth, args, target:target, addAction:\addToHead);
        }
    }

    off {|note|
        if (synthdef.hasGate) {
            //var synth = synths[note];
            synths.removeAt(note).set(\gate, 0)
            //synth.set(\gate, 0);
        }
    }

    note {|noteChan, note, debug=false|

        var noteonkey = "%_noteon".format(this.key).asSymbol;
        var noteoffkey = "%_noteoff".format(this.key).asSymbol;

        if (note.isNil) {
            note = (0..110);
        };

        MIDIdef.noteOn(noteonkey.debug("noteonkey"), {|vel, note, chan|
            this.on(note, vel, debug:debug);
        }, noteNum:note, chan:noteChan)
        .fix;

        MIDIdef.noteOff(noteoffkey.debug("noteoffkey"), {|vel, note, chan|
            this.off(note);
        }, noteNum:note, chan:noteChan)
        .fix;
    }

    disconnect {
        "%_noteon".format(this.key).debug("disconnect");
        MIDIdef.noteOn("%_noteon".format(this.key).asSymbol).permanent_(false).free;
        "%_noteoff".format(this.key).debug("disconnect");
        MIDIdef.noteOn("%_noteoff".format(this.key).asSymbol).permanent_(false).free;
    }

    print {
        //this.envir.copy.parent_(nil).getPairs.asCode.postln;
        "(\nS('%').set(".format(this.key).postln;
        this.envir.copy.parent_(nil)
        .getPairs
        .pairsDo({|k, v|
            "\t".post;
            k.asCode.post;
            ", ".post;
            v.asCode.post;
            ",".postln;
        });
        ")\n)".postln;

        this.node.print;
    }

    source_ {|pattern|

        var chain;

        if (pattern.isKindOf(Array)) {
            pattern = pattern.p
        };

        chain = Pchain(
            Pbind(
                \node_set, Pfunc({|evt|
                    // TODO server.bind
                    Server.default.makeBundle(Server.default.latency, {
                        var current = evt;
                        var exceptArgs = current[\exceptArgs];
                        var args = node.controlKeys(except: exceptArgs);
                        current = current.select({|v, k| args.includes(k) });
                        node.set(*current.getPairs)
                    });
                    1
                })
            ),
            pattern,
            Plazy({
                Pbind(
                    \out, Pfunc({node.bus.index}),
                    \group, Pfunc({node.group}),
                )
            })
        );

        super.source = PfsetC({ { this.changed(\stop) } },
            Plazy({

                synth = synth ?? {\default};

                if (isMono) {
                    Pmono(synth, \trig, 1) <> chain
                }{
                    Pbind() <> chain
                }
            })
        );
    }

    prInit {

        count = count + 1;
        keyval = "s%".asSymbol(count);
        clock = W.clock;
        color = Color.rand;
        synths = Order.new;
        nodewatcherfunc = {|obj, what|
            if ((what == \play) or: (what == \stop)) {
                isMonitoring = obj.isMonitoring
            }
        };
        //node = D("%_out".format(this.key).asSymbol);
        node = DNodeProxy().key_("%_out".format(keyval).asSymbol);
        node.color = color;
        node.addDependant(nodewatcherfunc);

        node.play;
        //ptrnproxy = PbindProxy();
        super.source = Pbind();
        this.quant = 4.0;

        cmdperiodfunc = {
            {
                node.wakeUp;
                if (isMonitoring) {
                    \cmdperiod.debug(node.key);
                    node.play
                };
            }.defer(0.5)
        };
        ServerTree.add(cmdperiodfunc);
        ^this
    }

    prInitSynth {|argSynth|

        synth = argSynth;
        synthdef = SynthDescLib.global.at(synth);
        if (synthdef.isNil) {
            synth = \default;
            synthdef = SynthDescLib.global.at(synth);
        };

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
            }/* {
            var default = cn.defaultValue;
            var spec = [0, default*2, \lin, 0, default].asSpec;
            this.addSpec(key, spec);
            }*/
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
        this.isMono.debug("mono");

        "set defaults from spec...".debug("ssynth");
        if (this.getSpec.notNil) {
            this.getSpec.keys.do({|key|
                var spec = this.getSpec[key];
                this.set(key, spec.default);
            });
        };

        controlNames = SynthDescLib.global.at(synth).controlNames;
        this.set(\instrument, synth.debug("synth"), \spread, 1, \pan, 0, \amp, -6.dbamp);
    }

    *initClass {
    }
}


