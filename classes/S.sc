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

    *hh {
        var obj = S(\hh).mono(\plaits_mono);
        obj.set(
            \engine, 15,
            \harm, 0.5,
            \timbre, 0.91,
            \morph, 0.2,
        );
        ^obj;
    }

    *sd {
        var obj = S(\sd).mono(\plaits_mono);
        obj.set(
            \engine, 14,
            \harm, 0.94,
            \timbre, 0.17,
            \morph, 0,
        );
        ^obj;
    }

    *bd {
        var obj = S(\bd).mono(\plaits_mono);
        obj.set(
            \engine, 13,
            \octave, 3,
            \harm, 0.32,
            \timbre, 0.8,
            \morph, 0.17,
        );
        ^obj;
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

    | {|val, adverb|

        if (val.isKindOf(Association)) {
            var num = adverb.asInteger;
            var prop = val.key;
            var spec = val.value.asSpec;
            Twister.knobs(num).cc(spec).label_("%_%".format(key, prop));
            this.pset(prop, Twister.knobs(num).asMap)
        }
    }

    << {|pattern, adverb|
        if (pattern.isKindOf(Array)) {
            pattern = pattern.p;
        } {
            if (pattern.isKindOf(Function)) {
                /*var repeats = inf;
                if (adverb.notNil) {
                    if(adverb.isNumber) {
                        repeats = adverb.asInteger;
                    }
                };*/
                pattern = PlazyEnvir(pattern);//.repeat(repeats)
            }
        };
        ptrn.source = pattern;
    }

    @ {|val, adverb|

        if (adverb.isNil and: val.isKindOf(Array)) {
            this.pset(*val);
        } {
            switch(adverb,
                // TODO: refactor this
                \deg, {
                    this.pset(\degree, val);
                },
                \dur, {
                    this.pset(\dur, val);
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

    quant_ {|quant|
        ptrn.quant = quant;
        super.quant = quant;
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
        node = D("d_%".format(key).asSymbol);
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

        ptrnproxy = EventPatternProxy(PbindProxy()).quant_(this.quant);
        ptrn = EventPatternProxy(Pbind()).quant_(this.quant);

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
            \delta, \freq, \degree, \octave, \gate, \fx, \vel,
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
