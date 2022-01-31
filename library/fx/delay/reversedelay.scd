(
synth: {arg sig_in;

    var in = sig_in * \reversedelay_input.ar(1, spec:ControlSpec(0, 2, \lin, 0, 1));
    var beatdur = \beatdur.kr(TempoClock.default.beatDur,
        spec:ControlSpec(1/4, 2, \lin, 0, TempoClock.default.beatDur));
    var delayL = \delayL.ar(1, spec:ControlSpec(0, 5, \lin, 0, 1));
    var delayR = \delayR.ar(1, spec:ControlSpec(0, 5, \lin, 0, 1));
    var feedbackL = \feedbackL.ar(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5));
    var feedbackR = \feedbackR.ar(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5));
    var crossfade = \crossfade.ar(20, spec: ControlSpec(0, 100, \lin, 0, 20));
    var mix = \reversedelay_mix.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5));
    var output = \reversedelay_output.kr(1, spec:ControlSpec(0, 2, \lin, 0, 1));

    var sig = LADSPA.ar(1, 1605,
        in,
        [delayL.lag(0.1), delayR.lag(0.1)] * beatdur,
        -60, // dry
        0, // wet
        [feedbackL.lag(0.1), feedbackR.lag(0.1)],
        crossfade
    );

    sig = in.blend(sig, mix);
    sig = sig * output;
    sig;
}
)