(
synth: {|in|

    var lforate = \phaser_rate.kr(0.1, spec:ControlSpec(0.01, 10, \lin, 0, 0.1, "phaser"));
    var skew = \phaser_skew.kr(0, spec:ControlSpec(-1, 1, \lin, 0, 0, "phaser"));
    var fb = \phaser_fb.kr(0.2, spec:ControlSpec(0, 0.95, \lin, 0, 0.2, "phaser"));
    var mod = \phaser_mod.kr(0.9, spec:ControlSpec(0, 1, \lin, 0, 0.9, "phaser") );
    var stages = \phaser_stages.kr(5, spec:ControlSpec(1, 16, \lin, 1, 5, "phaser"));
    var freq = \phaser_freq.kr(500, spec:ControlSpec(300, 3000, \lin, 0, 500, units:"phaser"));
    var sig = AnalogPhaser.ar(
        BBandPass.ar(in, freq),
        lfoinput: LFPar.ar(lforate),
        skew: skew,
        feedback: fb,
        modulation: mod,
        stages: stages
    );

    sig = in.blend(sig, \phaser_mix.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, "phaser")));

    sig;
},
doc: "
https://github.com/jatinchowdhury18/ChowDSP-VCV/blob/master/doc/manual.md#chow-phaser

CHOW Phaser is made up of two modules that together make up a port of the CHOW Phaser audio plugin. For a typical phaser effect, use a bipolar LFO as the CV input.

The skew knob emphasises different parts of the CV input, in a way inspired by the behaviour of Light-Dependent Resistors (LDRs).

The Feedback module contains two modulating allpass stages arranged in a feedback architecture. The amount of feedback is controlled by the feedback knob.

The Mod module contains a series of modulating allpass stages. The mod knob controls the mix of the modulated signal. The stages knob controls the number of allpass stages used.
"
)