/*
Synth
*/
S : EventPatternProxy {

    classvar <all;

    var <node, <cmdperiodfunc, <synthdef;

    var <instrument, <ptrn, <ptrnproxy, <out, <hasGate;

    var <>key, isMono=false, <synths, <>debug=false;

    *new {|key|

        var res;

        if (key.isNil) {
            key = "s_%".format(UniqueID.next).asSymbol;
            "using key %".debug("S");
        };
        res = all[key];
        if (res.isNil) {
            var def = SynthDescLib.global.at(key);
            var instr = \default;
            if (def.notNil)  {
                instr = key;
            };
            res = super.new.prInit(key).synth(instr);
            all[key] = res;
        };

        ^res;
    }

    *doesNotUnderstand {|selector|
        ^this.new(selector);
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
            if (val.isKindOf(Association)) {

                var prop = adverb;
                var num = val.key;

                // would like to find a better way to do this
                if (val.value.isNil) {
                    var cckey = Twister.knobs(num).cckey;
                    Evt.off(cckey, key);
                    this.pset(prop, nil);
                }{
                    var spec = val.value.asSpec;
                    var node = Ndef("midi_%_%".format(key, prop).asSymbol, {\val.kr(spec.default)});
                    var ccdefault = spec.default.linlin(spec.minval, spec.maxval, 0, 127);
                    var cckey = Twister.knobs(num).cckey;
                    Evt.on(cckey, key, {|data|
                        var val = data[\val];
                        node.set(\val, spec.map(val))
                    });
                    this.pset(prop, node);
                    this.changed(\midiknob, num, prop, spec);
                }

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

    view {
        ^U(\ngraph, this.node);
    }

    kb {
        ^U(\kb, this);
    }

    printSynthControls {
        S.printSynthControls(this.instrument);
    }

    on {arg midinote, vel=1;
        this.prNoteOn(midinote, vel);
    }

    off {arg midinote;
        this.prNoteOff(midinote);
    }

    vstctrls {
        ^this.node.vstctrls;
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

    prInit {|argKey|

        debug = false;
        key = argKey;
        instrument = \default;
        node = D("%".format(key).asSymbol);
        node.play;

        synths = Array.fill(127, {List.new});

        cmdperiodfunc = {
            {
                node.wakeUp
            }.defer(0.5)
        };
        ServerTree.add(cmdperiodfunc);
        this.prSetSource;
    }

    prInitSynth {|argSynth, argTemplate=\adsr|

        instrument = argSynth;
        if (argSynth.isFunction) {
            instrument = "synth_%".format(this.key).asSymbol;
            S.def(instrument, argSynth, argTemplate);
        };

        synthdef = SynthDescLib.global.at(instrument);

        if (synthdef.isNil) {
            var path = App.librarydir ++  "synths/" ++ instrument.asString ++ ".scd";
            var pathname = PathName(path.standardizePath);
            var name = pathname.fileNameWithoutExtension;
            var fullpath = pathname.fullPath;
            if (File.exists(fullpath)) {
                File.open(fullpath, "r").readAllString.interpret;
                synthdef = SynthDescLib.global.at(instrument);
            } {
                Error("synthdef not found").throw;
            }
        };

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
        })
    }

    prNoteOn {arg midinote, vel=1;

        var ignore = [\instrument,
            \root, \scale, \out, \group, \key, \dur, \legato,
            \delta, \stretch, \freq, \degree, \octave, \gate, \fx, \vel,
            \harmonic, \strum];

        if (node.isPlaying) {

            var evt = (this.envir ?? {()} )
            .reject({arg v, k;
                ignore.includes(k) or: v.isKindOf(Function);
            });

            var args = [\out, node.bus.index, \gate, 1, \freq, midinote.midicps, \vel, vel] ++ evt.asPairs();

            if (debug) {
                args.postln;
            };

            if (hasGate) {
                if (synths[midinote].last.isNil) {
                    synths[midinote].add( Synth(instrument, args, target:node.nodeID) );
                }
            } {
                Synth(instrument, args, target:node.nodeID)
            }
        }
    }

    prNoteOff {arg midinote;
        // popping from a queue seems more atomic
        // than dealing strictly with an array
        // removeAt(0) changes the size of the array
        // copying seems to produce better results
        // but i'm not sure why
        var mysynths = synths.copy;
        var synth = mysynths[midinote].pop;
        while({synth.isNil.not},{
            synth.set(\gate, 0);
            synth = mysynths[midinote].pop;
        });
    }

    *initClass {
        all = IdentityDictionary.new;
    }
}
