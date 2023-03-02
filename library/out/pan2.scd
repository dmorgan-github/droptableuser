(
synth: {|in|
    var sig = Pan2.ar(in,
        pos:\pan.kr(0, spec:ControlSpec(-1, 1, \lin, 0, 0, "stereo"))
    );
    sig;
};
)
