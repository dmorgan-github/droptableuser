(
synth: {arg sig_in;

    var in = sig_in * \input.ar(1);
    var fblevel = [\fbL.ar(0.3), \fbR.kr(0.5)];
    var delL = \delL.ar(3).lag(0.1) * 4.reciprocal;
    var delR = \delR.ar(4).lag(0.1) * 4.reciprocal;
    var tempo = \speed.ar(1).lag(0.1);
    var offsetL = \offsetL.ar(0).lag(0.1);
    var offsetR = \offsetR.ar(0).lag(0.1);

    var sig = HPF.ar(in, \hpf.kr(20));
    sig = FbC({arg fb;
        fb.reverse * fblevel + sig
    }, 16, [delL, delR] * tempo + [offsetL, offsetR]);

    sig = Splay.ar(sig, \spread.ar(0.5), 1, center:\pan.ar(0));
    sig * \output.kr(1);
},
specs: [
    \fbL -> ControlSpec(0.0, 1, \lin, 0.0, 0.3, "fb"),
    \fbR -> ControlSpec(0.0, 1, \lin, 0.0, 0.5, "fb"),
    \delL -> ControlSpec(1, 16, \lin, 0.125, 3, "delay"),
    \delR -> ControlSpec(1, 16, \lin, 0.125, 4, "delay"),
    \speed -> ControlSpec(0.001, 4, \lin, 0.0, 1, "delay"),
    \offsetL -> ControlSpec(0.0, 4, \lin, 0.0, 0, "delay"),
    \offsetR -> ControlSpec(0.0, 4, \lin, 0.0, 0, "delay"),
    \hpf -> ControlSpec(20, 10000, \lin, 0, 20, "filter"),
    \center -> ControlSpec(-1, 1, \lin, 0, 0, "stereo"),
    \pan -> ControlSpec(-1, 1, \lin, 0, 0, "stereo"),
    \input -> ControlSpec(0, 2, \lin, 0, 1, "vol"),
    \output -> ControlSpec(0, 2, \lin, 0, 1, "vol")
]
)
