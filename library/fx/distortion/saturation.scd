(
synth: {arg sig_in;

    var in = sig_in * \input.ar(1);
    var gain = [\gainL.ar(1), \gainR.ar(1)];
    var sig = (in * gain).tanh * (gain.reciprocal.sqrt);
    sig = LeakDC.ar(sig);
    Splay.ar(sig,
        spread:\spread.ar(1),
        center:\pan.ar(0)
    ) * \output.ar(1);
},
specs: [
    gainL: ControlSpec(1, 200, \lin, 0, 1, units:"fx"),
    gainR: ControlSpec(1, 200, \lin, 0, 1, units:"fx"),
    spread: ControlSpec(0,1,\lin,0, 1, units:"stereo"),
    pan: ControlSpec(-1,1,\lin,0,0, units:"stereo"),
    input: ControlSpec(0, 2, \lin, 0, 1, units:"fx"),
    output: ControlSpec(0, 2, \lin, 0, 1, units: "vol")
]
)