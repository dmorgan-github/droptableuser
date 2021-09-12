(
synth: {arg sig_in;

    var in = sig_in * \input.ar(1);
    var sig = Squiz.ar(in,
        pitchratio: \pitchratio.ar(12).midiratio,
        zcperchunk: \zcperchunk.ar(1)
    );
    Splay.ar(LeakDC.ar(sig),
        spread:\spread.ar(1),
        center:\pan.ar(0)
    ) * \output.ar(1);
},
specs: [
    pitchratio: ControlSpec(1, 24, \lin, 1, 12, "fx"),
    zcperchunk: ControlSpec(1, 100, \lin, 0, 1, "fx"),
    spread: ControlSpec(0,1,\lin,0, 1, units:"stereo"),
    pan: ControlSpec(-1,1,\lin,0,0, units:"stereo"),
    input: ControlSpec(0, 2, \lin, 0, 1, "vol"),
    output: ControlSpec(0, 2, \lin, 0, 1, units: "vol")
]
)