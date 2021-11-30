(
synth: {arg sig_in;

    var in = sig_in * \fbdelay_input.ar(1);
    var fblevel = [\fbL.kr(0.3), \fbR.kr(0.5)];
    var delL = \delL.kr(3).lag(0.1) * 4.reciprocal;
    var delR = \delR.kr(4).lag(0.1) * 4.reciprocal;
    var tempo = \beatDur.kr(TempoClock.default.beatDur).lag(0.1);

    var sig = HPF.ar(in, \hpf.kr(100));
    sig = FbC({arg fb;
        var fx = fb.reverse * fblevel + sig;
        SafetyLimiter.ar(fx);
    }, 4, [delL, delR] * tempo /*- ControlRate.ir.reciprocal*/);

    sig = in.blend(sig, \fbdelay_mix.kr(0.3));
    sig * \fbdelay_output.kr(1);
},
specs: [
    beatDur: ControlSpec(1/8, 4, \lin, 0.0, 1, "fb delay"),
    fbL: ControlSpec(0.0, 1.5, \lin, 0.0, 0.3, "fb delay"),
    fbR: ControlSpec(0.0, 1.5, \lin, 0.0, 0.5, "fb delay"),
    delL: ControlSpec(1, 16, \lin, 0, 3, "fb delay"),
    delR: ControlSpec(1, 16, \lin, 0, 4, "fb delay"),
    hpf:ControlSpec(20, 10000, \lin, 0, 100, "fb delay"),
    fbdelay_input: ControlSpec(0, 2, \lin, 0, 1, "fb delay"),
    fbdelay_output: ControlSpec(0, 2, \lin, 0, 1, "fb delay"),
    fbdelay_mix: ControlSpec(0, 1, \lin, 0, 0.3, "fb delay")
]
)
