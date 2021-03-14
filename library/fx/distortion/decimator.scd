(
synth: {arg sig_in;

    var in = sig_in * \input.ar(1);
    var sig = Decimator.ar(in,
        rate: 44100/\rate.ar(1).clip(1,10),
        bits: \bits.ar(24)
    );

    Splay.ar(LeakDC.ar(sig),
        spread:\spread.ar(1),
        center:\pan.ar(0)
    ) * \output.ar(1);
},
specs: [
    \rate -> ControlSpec(1, 10, \lin, 0, 1, units:"fx"),
    \bits -> ControlSpec(2, 24, \lin, 0, 24, units:"fx"),
    \spread -> ControlSpec(0,1,\lin,0, 1, units:"stereo"),
    \pan -> ControlSpec(-1,1,\lin,0,0, units:"stereo"),
    \input -> ControlSpec(0, 2, \lin, 0, 1, units:"vol"),
    \output -> ControlSpec(0, 2, \lin, 0, 1, units: "vol")
]
)
