/*
# 1408 Barry's Satan Maximiser
> k: Decay time (samples) (2 to 30)
> k: Knee point (dB) (-90 to 0)
> a: Input
< a: Output
*/
(
synth: {arg sig_in;

    var in = sig_in * \input.ar(1);
    var sig = LADSPA.ar(1, 1408,
        \decay.ar(10).lag(0.01),
        [
            \kneepointL.ar(-30).lag(0.01),
            \kneepointR.ar(-30).lag(0.01)
        ],
        in
    );

    sig = LeakDC.ar(sig) * 0.1;
    Splay.ar(sig,
        spread:\spread.ar(1),
        center:\center.ar(0)
    ) * \output.ar(1);
},
specs: [
    \decay -> ControlSpec(2, 30, \lin, 0, 10, units:"fx"),
    \kneepointL -> ControlSpec(-90, 1, \lin, 0, -30, units:"fx"),
    \kneepointR -> ControlSpec(-90, 1, \lin, 0, -30, units:"fx"),
    \spread -> ControlSpec(0,1,\lin,0, 1, units:"stereo"),
    \pan -> ControlSpec(-1,1,\lin,0,0, units:"stereo"),
    \input -> ControlSpec(0, 2, \lin, 0, 1, units:"vol"),
    \output -> ControlSpec(0, 2, \lin, 0, 1, units: "vol")
]
)