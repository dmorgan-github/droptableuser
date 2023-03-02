(
synth: {|in|
    var sig = Splay.ar(in,
        spread:\width.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, "stereo")),
        center:\pan.kr(0, spec:ControlSpec(-1, 1, \lin, 0, 0, "stereo"))
    );
    sig;
};
)
