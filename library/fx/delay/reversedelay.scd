(
synth: {arg sig_in;

    var in = sig_in * \reversedelay_input.ar(1);
    var sig = LADSPA.ar(1, 1605,
        in,
        [\delayL.ar(1).lag(0.1), \delayR.ar(1).lag(0.1)],
        -60, // dry
        0, // wet
        [\feedbackL.ar(0.5).lag(0.1), \feedbackR.ar(0.5).lag(0.1)],
        \crossfade.ar(20)
    );

    sig = in.blend(sig, \reversedelay_mix.kr(0.5));
    sig = sig * \reversedelay_output.kr(1);
    sig;
},
specs: [
    delayL: ControlSpec(0, 5, \lin, 0, 1, units:"reversedelay"),
    delayR: ControlSpec(0, 5, \lin, 0, 1, units:"reversedelay"),
    feedbackL: ControlSpec(0, 1, \lin, 0, 0.5, units:"reversedelay"),
    feedbackR: ControlSpec(0, 1, \lin, 0, 0.5, units:"reversedelay"),
    crossfade: ControlSpec(0, 100, \lin, 0, 20, units:"reversedelay"),
    reversedelay_mix: ControlSpec(0, 1, \lin, 0, 0.5, units:"reversedelay"),
    reversedelay_input: ControlSpec(0, 2, \lin, 0, 1, units:"vol"),
    reversedelay_output: ControlSpec(0, 2, \lin, 0, 1, units: "vol")
]
)