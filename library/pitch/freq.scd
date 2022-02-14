(
synth: {
    var glis = \glis.kr(0, spec: ControlSpec(0, 1, \lin, 0, 0, units:"pitch"));
    var in_freq = \freq.ar(261).lag(glis);
    var detune = \detunehz.kr(0,
        spec: ControlSpec(0, 10, \lin, 0, 0, units:"pitch")) * PinkNoise.ar(0.007).range(0.9, 1.1);
    var bend = \bend.ar(0, spec: ControlSpec(-12, 12, \lin, 0, 0, units:"pitch")).midiratio;
    var freqbend = in_freq * bend;
    var freq = Vibrato.ar([freqbend + detune.neg, freqbend + detune],
        \vrate.ar(6, spec: ControlSpec(0, 440, \lin, 0, 6, units:"pitch")),
        \vdepth.ar(0.0, spec: ControlSpec(0, 1, \lin, 0, 0, units:"pitch"))
    );
    freq
}
)