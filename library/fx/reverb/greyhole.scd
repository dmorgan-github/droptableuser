(
synth: {arg sig_in;

    var in = sig_in * \input.ar(1);
    var sig = Greyhole.ar(in,
        \delayTime.ar(2),
        \damp.ar(0),
        \size.ar(1),
        \diff.ar(0.707),
        \feedback.ar(0.9),
        \modDepth.ar(0.1),
        \modFreq.ar(2)
    );

    Splay.ar(sig,
        spread:\spread.ar(1),
        center:\pan.ar(0)
    ) * \output.ar(1);

},
specs: [
    delayTime: ControlSpec(0.1, 60, \lin, 0, 2, units:"fx"),
    damp: ControlSpec(0, 1, \lin, 0, 0, units:"fx"),
    size: ControlSpec(0.5, 5, \lin, 0, 1, units:"fx"),
    diff: ControlSpec(0,1, \lin, 0, 0.707, units:"fx"),
    feedback: ControlSpec(0,1, \lin,0, 0.9, units:"fx"),
    modDepth: ControlSpec(0, 1, \lin, 0, 0.1, units:"fx"),
    modFreq: ControlSpec(0, 10, \lin, 0, 2, units:"fx"),
    spread: ControlSpec(0,1,\lin,0, 1, units:"stereo"),
    pan: ControlSpec(-1,1,\lin,0,0, units:"stereo"),
    input: ControlSpec(0, 2, \lin, 0, 1, units:"vol"),
    output: ControlSpec(0, 2, \lin, 0, 1, units: "vol")
]
)