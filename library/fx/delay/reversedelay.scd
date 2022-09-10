(
synth: {arg sig_in;

    var in = sig_in;
    var beatdur = \revdelay_beatdur.kr(TempoClock.default.beatDur,
        spec:ControlSpec(1/4, 2, \lin, 0, TempoClock.default.beatDur, units:"reversedelay"));
    var delayL = \revdelay_delayL.ar(1, spec:ControlSpec(0, 5, \lin, 0, 1, units:"reversedelay"));
    var delayR = \revdelay_delayR.ar(1, spec:ControlSpec(0, 5, \lin, 0, 1, units:"reversedelay"));
    var feedbackL = \revdelay_fbL.ar(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, units:"reversedelay"));
    var feedbackR = \revdelay_fbR.ar(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, units:"reversedelay"));
    var crossfade = \revdelay_xfade.ar(20, spec: ControlSpec(0, 100, \lin, 0, 20, units:"reversedelay"));
    var mix = \revdelay_mix.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, units:"reversedelay"));

    var sig = LADSPA.ar(1, 1605,
        in,
        [delayL.lag(0.1), delayR.lag(0.1)] * beatdur,
        -60, // dry
        0, // wet
        [feedbackL.lag(0.1), feedbackR.lag(0.1)],
        crossfade
    );

    sig = in.blend(sig, mix);
    sig;
}
)