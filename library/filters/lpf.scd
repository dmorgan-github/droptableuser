(
synth:{|in|
    var lpf = \lpf.kr(2000, spec:ControlSpec(20, 20000, \exp, 0, 2000, "lpf"));
    LPF.ar(in, lpf);
}
)