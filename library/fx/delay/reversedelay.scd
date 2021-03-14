(
synth: {arg sig_in;

    var in = sig_in * \input.ar(1);
    var sig = LADSPA.ar(1, 1605,
        in,
        [\delayL.ar(1).lag(0.1), \delayR.ar(1).lag(0.1)],
        -60, // dry
        0, // wet
        [\feedbackL.ar(0.5).lag(0.1), \feedbackR.ar(0.5).lag(0.1)],
        \crossfade.ar(20)
    );

    Splay.ar(sig,
        spread:\spread.ar(0.5),
        center:\pan.ar(0)
    ) * \output.ar(1);
},
specs: [
    \delayL -> ControlSpec(0, 5, \lin, 0, 1, units:"fx"),
    \delayR -> ControlSpec(0, 5, \lin, 0, 1, units:"fx"),
    \feedbackL -> ControlSpec(0, 1, \lin, 0, 0.5, units:"fx"),
    \feedbackR -> ControlSpec(0, 1, \lin, 0, 0.5, units:"fx"),
    \crossfade -> ControlSpec(0, 100, \lin, 0, 20, units:"fx"),
    \spread -> ControlSpec(0,1,\lin,0, 1, units:"stereo"),
    \pan -> ControlSpec(-1,1,\lin,0,0, units:"stereo"),
    \input -> ControlSpec(0, 2, \lin, 0, 1, units:"vol"),
    \output -> ControlSpec(0, 2, \lin, 0, 1, units: "vol")
]
)