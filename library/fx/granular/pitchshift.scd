(
synth: {arg sig_in;

    var input = \ps_input.ar(1, spec:ControlSpec(0, 2.dbamp, \lin, 0, 1, "pitchshift"));
    var output = \ps_output.kr(1, spec: ControlSpec(0, 2.dbamp, \lin, 0, 1, "pitchshift"));
    var mix = \ps_mix.kr(0.3, spec:ControlSpec(0, 1, \lin, 0, 0.3, "pitchshift"));
    var ratio = \ps_ratio.kr(2, spec:ControlSpec(1/8, 4, \lin, 0, 2, "pitchshift"));

    var in = sig_in * input;
    var size = ~pswindowsize ?? { 2 };
    var sig = PitchShift.ar(in,
        size.debug("pswindowsize"),
        ratio,
        0.01, 0.01
    );

    sig = in.blend(sig, mix);
    sig * output;
}
)
