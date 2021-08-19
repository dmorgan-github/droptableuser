/*
Synth
*/

/*
presets
PdefPreset.all.clear
~a = PdefPreset(\kxu, namesToStore: [\rel, \legato, \res, \suslevel] )
~a.namesToStore
~a.addSet(\curr)
~a.addSet(\set1)
~a.getSetNames
~a.settings.printcsAll
~ui = PdefPresetGui(~a)
*/


S : Pdef {

    var <node, <cmdperiodfunc;

    *new {|key|
        var res = Pdef.all[key];
        if (res.isNil) {
            res = super.new(key).prInit.synth(key);
        };

        ^res;
    }

    *doesNotUnderstand {|key|
		var res = Pdef.all[key];
		if (res.isNil){
			res = S(key);
		};
		^res;
	}

    @ {|val, adverb|

        if (adverb.isNil and: val.isKindOf(Array)) {
            this.set(*val);
        } {
            this.set(adverb, val);
        }
    }

    synth {|synth, template=\adsr|
        this.prInitSynth(synth, template);
    }

    // TODO: refactor this
    view {
        U(\sgui, this)
        /*
        var node = this;
        var keys = node.getSpec.keys.asArray;
        var view = View().layout_(VLayout()).minSize_(Size(400, 300));
        var preset = PdefPreset(node.key, namesToStore: keys );
        PdefPresetGui(preset, parent: view);
        PdefGui(node, 20, parent:view);
        view.front;
        */
    }

    out {
        ^this.node.monitor.out
    }

    out_ {|bus|
        this.node.monitor.out = bus
    }

    source_ {|pattern|
        super.source = Pchain(
          pattern,
          Pbind(\out, Pfunc({node.bus.index}), \group, Pfunc({node.group}))
        )
    }

    prInit {
        clock = W.clock;
        // use D when converted to Ndef
        node = Ndef(this.key);
        node.play;
        this.source = Pbind();
        this.set(\nkey, this.key, \type, \composite, \types, [\note, \nset]);
        // don't think this is necessary
        // when using D:Ndef
        cmdperiodfunc = {
            {
                node.wakeUp;
                if (node.isMonitoring) {
                    \cmdperiod.debug(node.key);
                    node.play
                };
            }.defer(0.5)
        };
        ServerTree.add(cmdperiodfunc);
        ^this
    }

    prInitSynth {|argSynth, argTemplate=\adsr|
        var meta, synthdef;
        var instrument = argSynth;
        if (argSynth.isFunction) {
            instrument = "synth_%".format(this.key).asSymbol;
            S.def(instrument, argSynth, argTemplate);
        };

        synthdef = SynthDescLib.global.at(instrument);
        if (synthdef.isNil) {
            instrument = \default;
            synthdef = SynthDescLib.global.at(instrument);
        };

        synthdef
        .controls.reject({|cn|
            [\freq, \trig, \in, \buf, \gate, \glis, \bend].includes(cn.name.asSymbol)
        }).do({|cn|
            var key = cn.name.asSymbol;
            var spec = Spec.specs[key];
            if (spec.notNil) {
              this.addSpec(key, spec);
            }
        });

        meta = synthdef.metadata;
        if (meta.notNil and: {meta[\specs].notNil} ) {
            meta[\specs].keysValuesDo({|k, v|
                this.addSpec(k, v);
            })
        };

        this.set(\instrument, instrument);
    }

    *def {|inKey, inFunc, inTemplate=\adsr|
        var path = App.librarydir ++  "templates/" ++ inTemplate.asString ++ ".scd";
        var pathname = PathName(path.standardizePath);
        var fullpath = pathname.fullPath;

        if (File.exists(fullpath)) {
            var template = File.open(fullpath, "r").readAllString.interpret;
            template.(inKey, inFunc);
        } {
            Error("synth template not found").throw;
        };

        "built synth % with template %".format(inKey, inTemplate).postln;
    }

    *printSynths {
        SynthDescLib.all[\global].synthDescs
        .keys
        .reject({|key|
            key.asString.beginsWith("system") or: key.asString.beginsWith("pbindFx_")
        })
        .asArray
        .sort
        .do({|val| val.postln})
    }

    *printSynthControls {|synth|
        SynthDescLib.all[\global]
        .synthDescs[synth]
        .controls.do({|cn|
            [cn.name, cn.defaultValue].postln
        });
    }

    *loadSynths {
        var path = App.librarydir.standardizePath ++ "synths/*.scd";
        "loading synths: %".format(path).debug;
        path.loadPaths;
    }

    *initClass {
        Event.addEventType(\nset, {|server|
          ~id = Ndef(~nkey).nodeID;
          ~args = Ndef(~nkey).controlKeys(except: ~exceptArgs);
          ~eventTypes[\set].value(~server);
        });
    }
}

S2 : Pdef {

    var <node, <cmdperiodfunc, <synthdef;

    var <instrument, <ptrn, <ptrnproxy, <hasGate;

    var <cckey, <noteonkey, <noteoffkey;

    var isMono=false, <synths, <>debug=false;

    *new {|key|
        var res = Pdef.all[key];
        if (res.isNil) {
            res = super.new(key).prInit.synth(key);
        };

        ^res;
    }

    <+ {|val, adverb|
        if (adverb == \mono) {
            this.mono(val)
        } {
            if (adverb.notNil) {
                this.synth(val, adverb)
            } {
               this.synth(val)
            }
        }
    }

    << {|pattern, adverb|
        if (pattern.isKindOf(Array)) {
            pattern = pattern.p;
        } {
            if (pattern.isKindOf(Function)) {
                pattern = PlazyEnvir(pattern);
            }
        };
        ptrn.source = pattern;
    }

    // TODO: clean up lfos
    @ {|val, adverb|

        if (adverb.isNil and: val.isKindOf(Array)) {
            this.pset(*val);
        } {
            switch(adverb,
                // TODO: refactor this
                \deg, {
                    this.pset(\degree, val);
                },
                \oct, {
                    this.pset(\octave, val);
                },
                \leg, {
                    this.pset(\legato, val);
                },
                {
                    this.pset(adverb, val);
                }
            );
        }
    }

    // TODO: clean up lfos
    pset {|...args|

        var pairs;
        if (args.size.even.not) {
            Error("args must be even number").throw;
        };

        pairs = args.collect({arg v, i;
            if (i.even) {
                v;
            }{
                var k = args[i-1];
                if (v.isFunction) {
                    var lfo;
                    var key = "lfo_%".format(this.key);
                    var lfokey = (key ++ '_' ++ k).asSymbol;
                    "creating lfo node %".format(lfokey).debug(this.key);
                    Ndef(lfokey, v);
                }{
                    v
                }
            }
        });

        ptrnproxy.source.set(*pairs);
    }

    /*
    set {| ... args|
        //TODO: don't send all parameters to each
        super.set(*args);
        //this.node.set(*args);
    }
    */

    synth {|synth, template=\adsr|
        isMono = false;
        this.prInitSynth(synth, template);
    }

    mono {|synth, template=\mono|
        isMono = true;
        this.prInitSynth(synth, template);
    }

    fx {|index, fx, wet=1|
        node.fx(index, fx, wet);
    }

    kb {
        ^U(\kb, this);
    }

    on {arg midinote, vel=1;
        this.prNoteOn(midinote, vel);
    }

    off {arg midinote;
        this.prNoteOff(midinote);
    }

    // TODO: handle mono synth
    note {|noteChan, note|
        MIDIdef.noteOn(noteonkey, {|vel, note, chan|
            this.on(note, vel);
        }, noteNum:note, chan:noteChan)
        .fix;

        MIDIdef.noteOff(noteoffkey, {|vel, note, chan|
            this.off(note);
        }, noteNum:note, chan:noteChan)
        .fix;
    }

    disconnectNote {
        MIDIdef.noteOn(noteonkey).permanent_(false).free;
        MIDIdef.noteOff(noteoffkey).permanent_(false).free;
    }

    vstctrls {
        ^this.node.vstctrls;
    }

    view {
        U(\sgui, this)
    }

    *def {|inKey, inFunc, inTemplate=\adsr|
        var path = App.librarydir ++  "templates/" ++ inTemplate.asString ++ ".scd";
        var pathname = PathName(path.standardizePath);
        var fullpath = pathname.fullPath;

        if (File.exists(fullpath)) {
            var template = File.open(fullpath, "r").readAllString.interpret;
            template.(inKey, inFunc);
        } {
            Error("synth template not found").throw;
        };

        "built synth % with template %".format(inKey, inTemplate).postln;
    }

    *printSynths {
        SynthDescLib.all[\global].synthDescs
        .keys
        .reject({|key|
            key.asString.beginsWith("system") or: key.asString.beginsWith("pbindFx_")
        })
        .asArray
        .sort
        .do({|val| val.postln})
    }

    *printSynthControls {|synth|
        SynthDescLib.all[\global]
        .synthDescs[synth]
        .controls.do({|cn|
            [cn.name, cn.defaultValue].postln
        });
    }

    *loadSynths {
        var path = App.librarydir.standardizePath ++ "synths/*.scd";
        "loading synths: %".format(path).debug;
        path.loadPaths;
    }

    prInit {

        debug = false;
        noteonkey = "%_noteon".format(this.key).asSymbol;
        noteoffkey = "%_noteff".format(this.key).asSymbol;
        cckey = "%_cc".format(this.key).asSymbol;
        instrument = \default;
        node = D("%".format(this.key).asSymbol);
        node.play;
        synths = Array.newClear(128);
        cmdperiodfunc = {
            {
                node.wakeUp
            }.defer(0.5)
        };
        ServerTree.add(cmdperiodfunc);
        this.prSetSource;
    }

    prInitSynth {|argSynth, argTemplate=\adsr|

        var meta;
        instrument = argSynth;
        if (argSynth.isFunction) {
            instrument = "synth_%".format(this.key).asSymbol;
            S.def(instrument, argSynth, argTemplate);
        };

        synthdef = SynthDescLib.global.at(instrument);
        if (synthdef.isNil) {
            instrument = \default;
            synthdef = SynthDescLib.global.at(instrument);
        };
        meta = synthdef.metadata;
        if (meta.notNil and: {meta[\specs].notNil} ) {
            meta[\specs].keysValuesDo({|k, v|
                this.addSpec(k, v);
            })
        };

        synthdef
        .controls.reject({|cn|
            [\freq, \out, \trig, \in, \buf, \gate, \glis, \bend, \amp, \vel].includes(cn.name.asSymbol)
        }).do({|cn|
            var key = cn.name.asSymbol;
            this.set(key, cn.defaultValue)
        });

        hasGate = synthdef.hasGate;
    }

    prSetSource {

        var chain;

        // not sure if this is entirely necessary
        // but it seems to work well having a base pattern
        // and chaining a pattern on top for overrides
        ptrnproxy = EventPatternProxy(PbindProxy()).quant_(this.quant);
        ptrn = EventPatternProxy(Pbind()).quant_(this.quant);

        // allows for setting properties in fx
        chain = Pbind(
            "nodeset_func".asSymbol, Pfunc({|evt|
                var keys = node.controlKeys;
                var mypairs = List.new;

                keys.do({|k|
                    if (evt[k].isNil.not) {
                        mypairs.add(k);
                        mypairs.add(evt[k]);
                    };
                });
                //mypairs.asArray.postln;
                if (mypairs.size > 0) {
                    node.set(*mypairs.asArray);
                };
                1
            })
        )
        <> ptrnproxy
        <> ptrn
        <> Pbind(
            \out, Pfunc({node.bus.index}),
            \group, Pfunc({node.group}),
            \instrument, Pfunc({instrument}), // i believe this is ignored for pmono
            \amp, -10.dbamp
        );

        this.source = Plazy({
            if (isMono) {
                Pmono(instrument, \trig, 1) <> chain
            }{
                chain
            }
        });
    }

    prNoteOn {arg midinote, vel=1;
        var evt = this.envir ?? {()};
        var args = [\out, node.bus.index, \gate, 1, \freq, midinote.midicps, \vel, vel] ++ evt.asPairs();

        if (debug) {
            args.postln;
        };

        if (hasGate) {
            synths[midinote] = Synth(instrument, args, target:node.nodeID);
        } {
            Synth(instrument, args, target:node.nodeID)
        }
    }

    prNoteOff {arg midinote;
        if (hasGate) {
            synths[midinote].set(\gate, 0);
        }
    }

    *initClass {
        //all = IdentityDictionary.new;
    }
}
