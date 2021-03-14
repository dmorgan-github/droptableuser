/*
Synth
*/
S : EventPatternProxy {

    classvar <>defaultRoot, <>defaultScale, <>defaultTuning;

    var <key, <instrument, <node, <synths;

    var <>hasGate, <synthdef;

    var listenerfunc, cmdperiodfunc, <>debug, <out;

    *new {arg key, synth, template=\adsr;
        var res;
        res = Pdef.all[key];
        if (res.isNil) {
            res = super.new(nil).prInit(key);
            Pdef.all.put(key, res);
        };
        if (synth.isNil.not) {
            res.prInitSynth(key, synth, template);
            "S with key % initialied".format(key).inform;
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

    *def {|inKey, inFunc, inTemplate=\adsr|
        var path = App.librarydir ++  "templates/" ++ inTemplate.asString ++ ".scd";
        var pathname = PathName(path.standardizePath);
        var fullpath = pathname.fullPath;
        if (File.exists(fullpath)) {
            var template = File.open(fullpath, "r").readAllString.interpret;
            template.(inKey, inFunc);
        } {
            Error("synth template not found").throw;
        }
    }

    *printSynths {
        SynthDescLib.all[\global].synthDescs
        .keys
        .reject({|key| key.asString.beginsWith("system") or: key.asString.beginsWith("pbindFx_") })
        .asArray
        .sort
        .do({|val| val.postln})
    }

    *printSynthControls {|synth|
        SynthDescLib.all[\global].synthDescs[synth].controls.do({|cn| [cn.name, cn.defaultValue].postln});
    }

    *loadSynths {
        var path = App.librarydir.standardizePath ++ "synths/*.scd";
        "loading synths: %".format(path).debug;
        path.loadPaths;
    }

    *loadMixins {
        var path = App.librarydir.standardizePath ++ "mixins/*.scd";
        "loading mixins: %".format(path).debug;
        path.loadPaths;
    }

    *transport {|clock|
        U(\transport, clock);
    }

    synth {|synth, template=\adsr|
        this.prInitSynth(key, synth, template);
        ^this;
    }

    out_ {|bus=0|
        out = bus;
        this.node.monitor.out = out;
    }

    monitor {|fadeTime=0.02|
        this.node.play(fadeTime:fadeTime);
    }

    mute {|fadeTime=0.02|
        this.node.stop(fadeTime:fadeTime)
    }

    embedInStream {|inval, embed = true, default|

        var monitor = this.envir[\monitor];
        if (monitor.isNil.not and: {monitor.not}) {
            this.node.stop;
        }{
            if (this.node.isMonitoring.not) {
                this.node.play(fadeTime:fadeTime);
            };
        };
        super.embedInStream(inval, embed, default);
    }

    play {|fadeTime=0.02, argClock, protoEvent, quant, doReset=false|

        var monitor = this.envir[\monitor];
        if (monitor.isNil.not and: {monitor.not}) {
            this.node.stop;
        }{
            if (this.node.isMonitoring.not) {
                this.node.play(fadeTime:fadeTime);
            };
        };
        super.play(argClock, protoEvent, quant, doReset);
    }

    /*
    stop {|fadeTime=0.02|
    this.node.stop(fadeTime:fadeTime);
    super.stop;
    }
    */

    getSettings {
        ^this.envir.asDict;
    }

    postSettings {
        var str = "(\nvar settings = " ++ this.getSettings.asCompileString ++ ";\nS.%.set(*settings.getPairs);\n)".format(this.key);
        str.postln;
    }

    /*
    addPreset {|num|
    P.addPreset(this, num, this.getSettings);
    }

    loadPreset {|num|
    var preset = P.getPreset(this, num);
    this.set(*preset.getPairs);
    }

    removePreset {|num|
    var presets = P.getPresets(this);
    if (presets.isNil.not) {
    presets.removeAt(num)
    };
    }

    getPresets {
    ^P.getPresets(this);
    }

    getPreset {|num|
    ^P.getPreset(this, num);
    }
    */

    // TODO: should clear and remove any lfo if being replaced
    pset {arg ...args;

        var pairs;
        if (args.size.even.not) {
            Error("args must be even number").throw;
        };

        pairs = args.collect({arg v, i;
            if (i.even) {
                v;
            }{
                var k = args[i-1];
                if (v.isKindOf(Function)) {
                    var lfo;
                    var lfokey = (this.key ++ '_' ++ k).asSymbol;
                    "creating lfo node %".format(lfokey).debug(this.key);
                    Ndef(lfokey, v);
                }{
                    v
                }
            }
        });

        this.source = Pbind(*pairs)
        <>
        Pbind(\out, Pfunc({node.bus.index}), \group, Pfunc({node.group}));
    }

    on {arg midinote, vel=1;
        this.prNoteOn(midinote, vel);
    }

    off {arg midinote;
        this.prNoteOff(midinote);
    }

    panic {
        synths.do({arg list, i;
            var synth = list.pop;
            while({synth.isNil.not},{
                synth.free;
                synth = list.pop;
            });
        });
        //if (node.group.isNil.not) {
        //	node.group.free;
        //}
    }

    prInit {arg inKey;

        if (inKey.isNil) {
            Error("key not specified");
        };

        debug = false;
        key = inKey;
        synths = Array.fill(127, {List.new});

        node = Device(key);
        node.mold(2, \audio);
        node.play;

        cmdperiodfunc = {
            {
                \cmdperiod.debug(key);
                Ndef(key).wakeUp
            }.defer(0.5)
        };
        ServerTree.add(cmdperiodfunc);

        // adding to envir just doesn't seem to work
        this.source = Pbind(
            \out, Pfunc({node.bus.index}),
            \group, Pfunc({node.group})
        );

        this.set(
            \root, defaultRoot,
            \scale, Scale.at(defaultScale).copy.tuning_(defaultTuning),
            \amp, -10.dbamp
        );

        ^this;
    }

    prInitSynth {arg inKey, inSynth, inTemplate=\adsr;

        //var synthdef;
        var myspecs = ();
        var ignore = [\out, \freq, \gate, \trig, \retrig, \sustain, \bend];

        instrument = inSynth;

        if (inSynth.isKindOf(Function)) {
            instrument = inKey;
            S.def(instrument, inSynth, inTemplate);
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
        // check the synthdef
        if (synthdef.metadata.isNil.not) {
            if (synthdef.metadata[\specs].isNil.not) {
                myspecs = synthdef.metadata[\specs]
            }
        };

        // add specs from the synth controls
        synthdef.controls
        .reject({arg ctrl;
            myspecs[ctrl.name.asSymbol].isNil.not;
        })
        .do({arg ctrl;
            // check for a matching default spec
            var key = ctrl.name.asSymbol;
            var spec = Spec.specs[key];
            if (spec.isNil) {
                var max = if (ctrl.defaultValue < 1) {1} { min(20000, ctrl.defaultValue * 2) };
                spec = [0, max, \lin, 0, ctrl.defaultValue].asSpec;
            };
            myspecs[key] = spec.default_(ctrl.defaultValue);
        });

        myspecs.keys.do({arg k;
            if (ignore.includes(k)) {
                myspecs.removeAt(k);
            };
            if (k.asString.endsWith("lfo")) {
                myspecs.removeAt(k);
            };
        });

        myspecs.keysValuesDo({arg k, v;
            this.addSpec(k, v);
            // this sets all the properties in the environment
            // so they can be read from the ui
            this.set(k, v.default)
        });

        this.set(\instrument, instrument);
    }

    prNoteOn {arg midinote, vel=1;


        /*
        1. "I want instantaneous, zero-latency transitions: when I hit the button on my controller, I want my playing event to immediately end and the next one to start. I don’t care about note durs / deltas at all."

        This case is addressed in the linked question, and some other places. If you want full manual control simply pull notes from your event stream and play them yourself:

        ~stream = Pdef(\notes).asStream;

        ~stream.next(()).play; // next event
        ~stream.next(()).play; // next event
        ~stream.next(()).play; // next event
        One gotcha: you must have (\sendGate, false) in your event, else Event:play will automatically end the Event after \dur beats.
        */

        var ignore = [\instrument,
            \root, \scale, \out, \group, \key, \dur, \legato,
            \delta, \freq, \degree, \octave, \gate, \fx, \vel];

        if (node.isPlaying) {

            var evt = this.envir
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

    /*
    prBuildSynth {arg inKey, inFunc, inTemplate=\adsr;
    var path = App.librarydir ++  "templates/" ++ inTemplate.asString ++ ".scd";
    var pathname = PathName(path.standardizePath);
    var fullpath = pathname.fullPath;
    if (File.exists(fullpath)) {
    var template = File.open(fullpath, "r").readAllString.interpret;
    template.(inKey, inFunc);
    } {
    Error("synth template not found").throw;
    }
    }
    */

    *initClass {
        defaultTuning = \et12;
        defaultRoot = 4;
        defaultScale = \dorian;
    }
}
