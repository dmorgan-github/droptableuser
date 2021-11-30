(
synth: {arg sig_in;

    var in = sig_in * \ps_input.ar(1);
    var size = ~pswindowsize.debug("pswindowsize") ?? { 2 };
    var sig = PitchShift.ar(in, size, \ps_ratio.kr(2), 0.01, 0.01);

    sig = in.blend(sig, \ps_mix.kr(0.3));
    sig * \ps_output.kr(1);
},
specs: [

    ps_ratio: ControlSpec(1/8, 4, \lin, 0, 2, "pitchshift"),
    ps_input: ControlSpec(0, 2, \lin, 0, 1, "pitchshift"),
    ps_output: ControlSpec(0, 2, \lin, 0, 1, "pitchshift"),
    ps_mix: ControlSpec(0, 1, \lin, 0, 0.3, "pitchshift")
]
)
