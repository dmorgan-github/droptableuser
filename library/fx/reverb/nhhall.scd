(
synth: {arg sig_in;

    var in = sig_in * \input.kr(1);

    var sig = NHHall.ar(in,
        \rt60.ar(1).lag(0.1),
        \stereo.ar(0.5),
        \lowFreq.ar(200),
        \lowRatio.ar(0.5),
        \hiFreq.ar(4000),
        \hiRatio.ar(0.5),
        \earlyDiffusion.ar(0.5),
        \lateDiffusion.ar(0.5),
        \modRate.ar(0.2),
        \modDepth.ar(0.3)
    );

    Splay.ar(sig,
        spread:\spread.ar(1),
        center:\pan.ar(0)
    ) * \output.ar(1);
},
specs: [
    \rt60 -> ControlSpec(0.1, 60, \lin, 0.0, 1, units:"fx"),
    \stereo -> ControlSpec(0, 1, \lin, 0, 0.5, units:"fx"),
    \lowFreq -> ControlSpec(20, 20000, \exp, 0, 200, units:"fx"),
    \lowRatio -> ControlSpec(0, 1, \lin, 0, 0.5, units:"fx"),
    \hiFreq -> ControlSpec(20, 20000, \exp, 0, 40000, units:"fx"),
    \hiRatio -> ControlSpec(0, 1, \lin, 0, 0.5, units:"fx"),
    \earlyDiffusion -> ControlSpec(0, 1, \lin, 0, 0.5, units:"fx"),
    \lateDiffusion -> ControlSpec(0, 1, \lin, 0, 0.5, units:"fx"),
    \modRate -> ControlSpec(0, 1, \lin, 0, 0.2, units:"fx"),
    \modDepth -> ControlSpec(0,1,\lin, 0, 0.3, units:"fx"),
    \spread -> ControlSpec(0,1,\lin,0, 1, units:"stereo"),
    \pan -> ControlSpec(-1,1,\lin,0,0, units:"stereo"),
    \input -> ControlSpec(0, 2, \lin, 0, 1, units:"vol"),
    \output -> ControlSpec(0, 2, \lin, 0, 1, units: "vol")
]
)