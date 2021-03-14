(
synth: {arg sig_in;
    var in = sig_in * \input.ar(1);
    var del = \del.ar(0.2).lag(0.1);
    var decay = \decay.ar(1).lag(0.1);
    var sig = CombC.ar(in, 4, del, decay);
    sig = LeakDC.ar(sig);
    Splay.ar(sig,
        spread:\spread.ar(1),
        center:\pan.ar(0)
    ) * \output.ar(1);
},
specs: [
    \decay -> ControlSpec(-16, 16, \lin, 0, 1, units:"fx"),
    \del -> ControlSpec(0.001, 4.0, \lin, 0, 0.2, units:"fx"),
    \spread -> ControlSpec(0,1,\lin,0, 1, units:"stereo"),
    \pan -> ControlSpec(-1,1,\lin,0,0, units:"stereo"),
    \input -> ControlSpec(0, 2, \lin, 0, 1, units:"vol"),
    \output -> ControlSpec(0, 2, \lin, 0, 1, units: "vol")
]
)