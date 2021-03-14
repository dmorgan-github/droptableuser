AdCVerb.maxTime = 10;
(
synth: {arg sig_in;

    var in = sig_in * \input.ar(1);
    var sig = AdCVerb.ar(in,
        revTime:\revTime.ar(3),
        hfDamping:\hfDamping.ar(0.1),
        nOuts:2,
        predelay:\predelay.ar(0.02),
        numCombs:8,
        numAllpasses:4,
        inFilter:\inFilter.ar(0.6),
        combScale:\combScale.ar(3).lag(0.1),
        apScale:\apScale.ar(3).lag(0.1)
    );

    Splay.ar(sig,
        spread:\spread.ar(1),
        center:\pan.ar(0)
    ) * \output.ar(1);
},
specs: [
    \revTime -> ControlSpec(0.1, 60, \lin, 0.0, 3, units:"fx"),
    \hfDamping -> ControlSpec(0, 1, \lin, 0.0, 0.1, units:"fx"),
    \predelay -> ControlSpec(0, 30, \lin, 0, 0.02, units:"fx"),
    \inFilter -> ControlSpec(0, 1, \lin, 0, 0.6, units:"fx"),
    \combScale -> ControlSpec(0.1, 10, \lin, 0, 3, units:"fx"),
    \apScale -> ControlSpec(0.1, 10, \lin, 0, 3, units:"fx"),
    \spread -> ControlSpec(0,1,\lin,0, 1, units:"stereo"),
    \pan -> ControlSpec(-1,1,\lin,0,0, units:"stereo"),
    \input -> ControlSpec(0, 2, \lin, 0, 1, units:"vol"),
    \output -> ControlSpec(0, 2, \lin, 0, 1, units: "vol")
]
)
