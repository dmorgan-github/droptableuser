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

/*
S {

    *create {|key, synth|

        var envir = currentEnvironment;
        var res = envir[key];

        if (res.isNil) {

            if (synth.isKindOf(Symbol)) {
                var src = synth.asString;
                res = case
                {src.beginsWith("vst:")} {
                    VstSSynth(src[4..].asSymbol).key_(key)
                }
                {src.beginsWith("midi:")} {
                    MidiSSynth(src[5..].asSymbol).key_(key)
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
*/

// TODO: this hasn't been tested
MidiIDef : IDef {

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
            /*
            Pbind(
                \type, \midi,
                \midicmd, \noteOn,
                \midiout, Pfunc({midiout}),
                \chan, Pfunc({notechan})
            ),
            */
            pattern
        );

        super.source = src;
    }

    prInitSynth {|argSynth|

        var args;// = argSynth.asString.split($:);

        // TODO: refactor
        midiout = MIDIOut.newByName("IAC Driver", "Bus 1");
        midiout.connect;

        args = argSynth.asString.split($,);
        notechan = args[0].asInteger;
        returnbus = args[1].asInteger;

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

VstIDef : IDef {

    var <>vstsynthdef=\vsti;
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

    savePresetAs {|name|
        var path = App.librarydir +/+ "preset" +/+ name;
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
            var args;// = argSynth.asString.split($:);
            args = argSynth.asString.split($/);
            plugin = args[0];
            if (args.size > 1){
                vstpreset = args[1];
                vstpreset = App.librarydir +/+ "preset" +/+ vstpreset;
            };
            // TODO: what's the difference between synth and vstsynthdef?
            // seems like vstsynthdef is unecessary
            synth = vstsynthdef;
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

            this.set('type', 'composite', 'types', [\vst_midi, \vst_set], 'vst', vstplugin, \spread, 1, \pan, 0)
            //this.set('type', \vst_midi, 'vst', vstplugin, \spread, 1, \pan, 0)

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

IDef : EventPatternProxy {

    var <node, <cmdperiodfunc, <>color, <key;
    var <>isMono=false, <synth;
    var <isMonitoring, <nodewatcherfunc;
    var <metadata, <controlNames;
    var <synths, <synthdef, <pbindproxy;
    var <s, <objects;
    var midictrl;

    *new {|key|
        ^super.new.prInit(key);
    }

    at {|num|
        ^objects[num]
    }

    put {|num, val|

        // TODO: need to improve bookkeeping
        if (val.isNil) {
            objects.removeAt(num);
            objects.changed(\put, [num, nil]);
            this.s.removeAt(num);
            this.fx(num, nil);
        } {
            objects.put(num, val);
            objects.changed(\put, [num, val]);

            if (val.isKindOf(Association)) {
                var key = val.key;
                var item = val.value;
                switch(key,
                    \fx, {
                        this.fx(num, item)
                    },
                    \ptrn, {
                        //so ugly
                    },
                    {
                        this.s.put(num, val)
                    }
                )
            } {
                this.s.put(num, val)
            }
        }
    }

    @ {|val, adverb|

        if (adverb.isNil and: val.isKindOf(Array)) {
            this.set(*val);
        } {
            if (val.isNil) {
              ^this.get(adverb)
            } {
              this.set(adverb, val)
            }
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

    m {
        if (this.midictrl.isNil) {
            this.midictrl = MidiCtrl(this);
        };
        ^this.midictrl;
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
        // TODO: figure out how to simplify
        this.releaseDependants;
        this.clearHalo;
        this.node.clear;
        this.synths.clear;
        this.pbindproxy.clear;
        this.objects.clear;
        this.s.release;
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

    view {
        ^Ui('sgui').envir_(topEnvironment).view(this);
    }

    gui {
        this.view.front
    }

    kill {|ids|
        ids.asArray.do({|id|
            Synth.basicNew(this.synth, Server.default, id).free
        });
    }

    mute {
        this.node.stop
    }

    unmute {
        this.node.play
    }

    out {
        ^this.node.monitor.out
    }

    out_ {|bus|
        this.node.monitor.out = bus
    }

    key_ {|val|
        key = val;
        node.key = "%_out".format(val).asSymbol;
    }

    on {|note, vel=127, extra, debug=false|

        var evt = this.envir ?? ();
        var args;
        var out = this.node.bus.index;
        var target = this.node.group.nodeID;

        if (extra.notNil) {
            extra = extra.asDict;
            evt = evt ++ extra;
        };

        args = [\out, out, \gate, 1, \freq, note.midicps]
        ++ evt
        .copy
        .put(\vel, (vel/127).squared)
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

    print {
        //this.envir.copy.parent_(nil).getPairs.asCode.postln;
        "[".format(this.key).postln;
        this.envir.copy.parent_(nil)
        .getPairs
        .pairsDo({|k, v|
            "\t".post;
            k.asCode.post;
            ", ".post;
            v.asCode.post;
            ",".postln;
        });
        "]".postln;

        this.node.print;
    }

    source_ {|pattern|

        var chain;

        chain = Pchain(
            /*
            Pbind(
                \node_set, Pfunc({|evt|
                    // TODO server.bind - takes into account latency
                    var pairs;
                    var current = evt;
                    var exceptArgs = current[\exceptArgs];
                    var args = node.controlKeys(except: exceptArgs);
                    current = current.select({|v, k| args.includes(k) });
                    pairs = current.getPairs;
                    // not sure if this is the best way
                    if (pairs.size > 0) {
                        Server.default.makeBundle(Server.default.latency, {
                            node.set(*pairs)
                        });
                    };
                    1
                })
            ),
            */
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
            synth = synth ?? {\default};
            if (isMono) {
                // not sure how to make composite event work with pmono
                Pmono(synth, \trig, 1) <> chain
            }{
                Pbind()
                <> chain
            }
        })

    }

    prInit {|argKey|

        var synthfunc, me = this, ptrnfunc;
        key = argKey.asSymbol;

        color = Color.rand;
        node = DNodeProxy().key_("%_out".format(key).asSymbol);
        node.color = color;

        this.clock = W.clock;
        this.quant = 4.0;

        synths = Order.new;
        objects = Order();
        s = M();

        synthfunc = {|obj, what, vals|
            var key = me.key;
            fork {
                await {|done|
                    s.add(key);
                    Server.default.sync;
                    done.value(\ok);
                };
                me.synth = key;
            };
        };
        this.s.addDependant(synthfunc);

        ptrnfunc = {|obj, what, vals|
            var ptrns = objects
            .select({|obj|
                obj.isKindOf(Association) and: {obj.key == \ptrn}
            })
            .collect({|val|
                var key = val.key;
                var item = val.value;
                if (item.isKindOf(Array)) {
                    item.p
                }{
                    item
                }
            });

            if (ptrns.size > 0) {
                if (ptrns.size > 1) {
                    me.source = Ppar(ptrns)
                } {
                    me.source = ptrns[0]
                }
            }{
                me.source = Pbind()
            }
        };
        objects.addDependant(ptrnfunc);

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
                    \cmdperiod.debug(node.key);
                    node.play
                };
            }.defer(0.5)
        };
        ServerTree.add(cmdperiodfunc);
        this.prInitSynth(argKey);
        ^this
    }

    prInitSynth {|argSynth|

        synth = argSynth;
        synthdef = SynthDescLib.global.at(synth);

        if (synthdef.isNil) {
            "synth does not exist".debug(synth)
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

            //"set defaults from spec...".debug("ssynth");
            if (this.getSpec.notNil) {
                this.getSpec.keys.do({|key|
                    var spec = this.getSpec[key];
                    this.set(key, spec.default);
                });
            };

            controlNames = SynthDescLib.global.at(synth).controlNames;
            this.set(\instrument, synth.debug("synth"), \spread, 1, \pan, 0);
        }
    }

    *initClass {
    }
}


