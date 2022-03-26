(
synth: {arg in;

    var mix = \ps_mix.kr(0.3, spec:ControlSpec(0, 1, \lin, 0, 0.3, "pitchshift"));
    var ratio = \ps_ratio.kr(2, spec:ControlSpec(1/8, 4, \lin, 0, 2, "pitchshift"));

    var size = ~pswindowsize ?? { 2 };
    var sig = PitchShift.ar(in,
        size.debug("pswindowsize"),
        ratio,
        0.01, 0.01
    );

    sig = in.blend(sig, mix);
    sig
}
)
