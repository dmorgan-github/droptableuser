(
synth: {arg in;

    /*
    var du = TempoClock.default.beatDur/4;
    var fbL = \delay_fbL.kr(0.3, spec:ControlSpec(0.0, 1.5, \lin, 0.0, 0.3, "delay"));
    var fbR = \delay_fbR.kr(0.5, spec:ControlSpec(0.0, 1.5, \lin, 0.0, 0.5, "delay"));
    var delL = \delay_delL.kr(3, spec:ControlSpec(1/4, 16, \lin, 0, 3, "delay"));
    var delR = \delay_delR.kr(4, spec:ControlSpec(1/4, 16, \lin, 0, 4, "delay"));
    var delayunit = \delay_delayunit.kr(du,
        spec:ControlSpec(1/16, 1, \lin, 0.0, du, "delay")).lag(0.1);
    var hpf = \delay_hpf.kr(100, spec:ControlSpec(20, 10000, \lin, 0, 100, "delay"));
    var mix = \delay_mix.kr(0.3, spec: ControlSpec(0, 1, \lin, 0, 0.3, "delay"));

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

    /*
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
    */

    var sig = in;
    var tempo = TempoClock.default.beatDur;
    var beatdur = \beatdur.kr(tempo, spec:ControlSpec(0.001, 4, \lin, 0, tempo, units:"delay") );
    var hpf = \delay_hpf.kr(100, spec:ControlSpec(20, 10000, \lin, 0, 100, "delay")); 
    var lpf = \delay_lpf.kr(20000, spec:ControlSpec(10000, 20000, \lin, 0, 20000, "delay"));
    var res = \delay_res.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"delay"));
    var lfoHz = \delay_lfohz.kr(0, spec: ControlSpec(0, 10, \lin, 0, 0, units:"delay"));
    var lfophase = \delay_lfophase.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"delay"));
    var lfodepth = \delay_lfodepth.kr(0, spec: ControlSpec(0, 1, \lin, 0, 0, units:"delay")).lag(0.01);
    var lfo = SinOsc.kr(lfoHz, [0pi, lfophase * pi]).unipolar(lfodepth);
    var time = \delay_time.kr(1, spec:ControlSpec(0.001, 20, \lin, 0.08, units:"delay"));
    var feedback = \delay_feedback.kr(0, spec:ControlSpec(0, 2, \lin, 0, 0, units:"delay"));
    var width = \delay_width.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, units:"delay"));
    var ratio = \delay_ratio_right.kr(1, spec:ControlSpec(1, 2, \lin, 0, 1, units:"delay"));

    time = ~delaytime ?? time; 

    sig = FbC({arg fb;
        var fx = fb * feedback + sig;
        Limiter.ar(fx, 1)
    }, 20, time.value.debug("delaytime").lag(0.01) * (1 + lfo) * [1, ratio]);

    sig = HPF.ar(sig, hpf);
    sig = BLowPass4.ar(sig, lpf, res.linlin(0, 1, 1, 0.001));
    sig = Splay.ar(sig, spread: width, center: 0);
    sig = in.blend(sig, \delay_mix.kr(0.4, spec: ControlSpec(0, 1, \lin, 0, 0.4, "delay") ));
    sig


},
presets: ()
)


