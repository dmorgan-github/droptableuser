(
synth: {arg sig_in;

    var input = \fbdelay_input.ar(1, spec: ControlSpec(0, 2.dbamp, \lin, 0, 1, "fb delay"));
    var fbL = \fbL.kr(0.3, spec:ControlSpec(0.0, 1.5, \lin, 0.0, 0.3, "fb delay"));
    var fbR = \fbR.kr(0.5, spec:ControlSpec(0.0, 1.5, \lin, 0.0, 0.5, "fb delay"));
    var delL = \delL.kr(3, spec:ControlSpec(1, 16, \lin, 0, 3, "fb delay"));
    var delR = \delR.kr(4, spec:ControlSpec(1, 16, \lin, 0, 4, "fb delay"));
    var beatDur = \beatDur.kr(TempoClock.default.beatDur, spec:ControlSpec(1/8, 4, \lin, 0.0, 1, "fb delay"));
    var hpf = \hpf.kr(100, spec:ControlSpec(20, 10000, \lin, 0, 100, "fb delay"));
    var mix = \fbdelay_mix.kr(0.3, spec: ControlSpec(0, 1, \lin, 0, 0.3, "fb delay"));
    var output = \fbdelay_output.kr(1, spec:ControlSpec(0, 2.dbamp, \lin, 0, 1, "fb delay"));

    var sig;
    var in = sig_in * input;
    var tempo = beatDur.lag(0.1);
    var fblevel = [fbL, fbR];
    delL = delL.lag(0.1) * 4.reciprocal;
    delR = delR.lag(0.1) * 4.reciprocal;

    sig = HPF.ar(in, hpf);
    sig = FbC({arg fb;
        var fx = fb.reverse * fblevel + sig;
        fx
    }, 4, [delL, delR] * tempo /*- ControlRate.ir.reciprocal*/);

    sig = in.blend(sig, mix);
    sig * output;
}
)
