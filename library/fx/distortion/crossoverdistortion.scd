(
synth: {arg sig_in;

    var in = sig_in * \input.ar(1);
    var sig = CrossoverDistortion.ar(in,
        amp: \crossover.ar(0.5),
        smooth: \smooth.ar(0.5)
    );

    Splay.ar(LeakDC.ar(sig) * 0.1,
        spread:\spread.ar(1),
        center:\pan.ar(0)
    ) * \output.ar(1);
},
specs: [
    crossover: ControlSpec(0, 1, \lin, 0, 0.5, units:"fx"),
    smooth: ControlSpec(0, 1, \lin, 0, 0.5, units:"fx"),
    spread: ControlSpec(0,1,\lin,0, 1, units:"stereo"),
    pan: ControlSpec(-1,1,\lin,0,0, units:"stereo"),
    input: ControlSpec(0, 2, \lin, 0, 1, units:"vol"),
    output: ControlSpec(0, 2, \lin, 0, 1, units: "vol")
]
)