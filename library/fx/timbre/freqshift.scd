(
synth: {arg sig_in;

    var in = sig_in * \input.ar(1);
    var freq = \freq.ar(3);
    var depth = \depth.ar(0);
    var fleft = freq - (freq * depth);
    var fright = freq + (freq * depth);
    var sig = FreqShift.ar(in, [fleft,fright]);
    Splay.ar(sig,
        spread:\spread.ar(1),
        center:\pan.ar(0)
    ) * \output.ar(1);
},
specs: [
    \freq -> ControlSpec(0.0, 800, \lin, 0.0, 3, units:"fx"),
    \depth -> ControlSpec(0, 1, \lin, 0, 0, units:"fx"),
    \spread -> ControlSpec(0,1,\lin,0, 1, units:"stereo"),
    \pan -> ControlSpec(-1,1,\lin,0,0, units:"stereo"),
    \input -> ControlSpec(0, 2, \lin, 0, 1, units:"vol"),
    \output -> ControlSpec(0, 2, \lin, 0, 1, units: "vol")
]
)