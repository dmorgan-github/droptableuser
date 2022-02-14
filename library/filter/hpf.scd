(
synth:{|in, gate, freq, aeg|
    var hpf = \hpf.kr(20, spec:ControlSpec(20, 8000, \exp, 0, 20, "hpf"));
    HPF.ar(in, hpf);
}
)