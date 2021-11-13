(
synth: {arg sig_in;

    var in = sig_in * \input.ar(1);
    var fblevel = [\fbL.kr(0.3), \fbR.kr(0.5)];
    var delL = \delL.kr(3).lag(0.1) * 4.reciprocal;
    var delR = \delR.kr(4).lag(0.1) * 4.reciprocal;
    var tempo = \beatDur.kr(TempoClock.default.beatDur).lag(0.1);

    var sig = HPF.ar(in, \hpf.kr(20));
    sig = FbC({arg fb;
        fb.reverse * fblevel + sig
    }, 4, [delL, delR] * tempo - ControlRate.ir.reciprocal);

    sig * \output.kr(1);
},
specs: [
    beatDur: ControlSpec(1/8, 4, \lin, 0.0, 1, "fb delay"),
    fbL: ControlSpec(0.0, 1, \lin, 0.0, 0.3, "fb delay"),
    fbR: ControlSpec(0.0, 1, \lin, 0.0, 0.5, "fb delay"),
    delL: ControlSpec(1, 16, \lin, 0.125, 3, "fb delay"),
    delR: ControlSpec(1, 16, \lin, 0.125, 4, "fb delay"),
    hpf:ControlSpec(20, 10000, \lin, 0, 20, "fb delay"),
    input: ControlSpec(0, 2, \lin, 0, 1, "fb delay"),
    output: ControlSpec(0, 2, \lin, 0, 1, "fb delay")
]
)
