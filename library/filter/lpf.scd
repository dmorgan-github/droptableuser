(
synth:{|in, gate, freq, aeg|

    var ffreq = \ffreq.kr(2000, spec:ControlSpec(20, 20000, \exp, 0, 2000, "lpf"));
    var res = \res.kr(0,
        spec: ControlSpec(0, 1, \lin, 0, 0, "lpf")
    ).linlin(0, 1, 1.4, 0.001);

    BLowPass.ar(in, ffreq, res);
}
)