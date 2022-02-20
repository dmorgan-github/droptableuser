(
synth: {
    var freq = \freq.ar(261).lag(\glis.kr(0));
    var modratio = \modratio.ar(1, spec:ControlSpec(0.25, 20, \lin, 0, 1, "pitch"));
    var index = \index.ar(0,
        spec:ControlSpec(0, 2pi, \lin, 0, 0, "pitch")
    ) * freq * modratio;
    var lforate = \fmlforate.kr(1, spec:ControlSpec(0.1, 80, \lin, 0, 1, "pitch"));
    var lfodepth = \fmlfodepth.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, "pitch"));
    var lfo = ~fmlfo ?? { SinOsc.ar(lforate).unipolar(lfodepth) };

    freq = freq + (SinOsc.ar(freq * modratio) * index * lfo);
    freq
}
)