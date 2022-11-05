(
synth: {arg in;

    /*

    var du = TempoClock.default.beatDur/4;
    var fbL = \fbdelay_fbL.kr(0.3, spec:ControlSpec(0.0, 1.5, \lin, 0.0, 0.3, "fb delay"));
    var fbR = \fbdelay_fbR.kr(0.5, spec:ControlSpec(0.0, 1.5, \lin, 0.0, 0.5, "fb delay"));
    var delL = \fbdelay_delL.kr(3, spec:ControlSpec(1/4, 16, \lin, 0, 3, "fb delay"));
    var delR = \fbdelay_delR.kr(4, spec:ControlSpec(1/4, 16, \lin, 0, 4, "fb delay"));
    var delayunit = \fbdelay_delayunit.kr(du,
        spec:ControlSpec(1/16, 1, \lin, 0.0, du, "fb delay")).lag(0.1);
    var hpf = \fbdelay_hpf.kr(100, spec:ControlSpec(20, 10000, \lin, 0, 100, "fb delay"));
    var mix = \fbdelay_mix.kr(0.3, spec: ControlSpec(0, 1, \lin, 0, 0.3, "fb delay"));

    var sig;
    var fblevel = [fbL, fbR];
    delL = delL.lag(0.1);
    delR = delR.lag(0.1);

    sig = HPF.ar(in, hpf);
    sig = FbC({arg fb;
        var fx = fb * fblevel + sig;
        fx
    }, 4, delayunit * [delL, delR]);

    sig = in.blend(sig, mix);
    sig
    */

    var sig;
    var du = TempoClock.default.beatDur/4; // 16th notes
    var hpf = \delay_hpf.kr(100, spec:ControlSpec(20, 10000, \lin, 0, 100, "delay"));
    var delL = \delay_delL.kr(3, spec:ControlSpec(1/8, 16, \lin, 0, 3, "delay"));
    var delR = \delay_delR.kr(4, spec:ControlSpec(1/8, 16, \lin, 0, 4, "delay"));
    var fbL = \delay_fbL.kr(0.3, spec:ControlSpec(0.0, 1.5, \lin, 0.0, 0.3, "delay"));
    var fbR = \delay_fbR.kr(0.5, spec:ControlSpec(0.0, 1.5, \lin, 0.0, 0.5, "delay"));
    var delayunit = \delay_unit.kr(du, spec:ControlSpec(1/16, 1, \lin, 0.0, du, "delay"));

    sig = HPF.ar(in, hpf);
    sig = SwitchDelay.ar(sig, 0, 1, delayunit * [delL, delR], [fbL, fbR], 20);
    sig = in.blend(sig, \delay_mix.kr(0.3, spec: ControlSpec(0, 1, \lin, 0, 0.3, "delay") ));
    sig

}
)


