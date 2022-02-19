(
synth:{|in, gate, freq, aeg|
    var fenv = 1-\snappy.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, "filter"));
    var fatkcurve = \fatkcurve.kr(-4);
    var fdeccurve = \fdeccurve.kr(-4);
    var frelcurve = \frelcurve.kr(-4);
    var feg =  Env.adsr(
        \fatk.kr(0),
        \fdec.kr(0.2),
        \fsuslevel.kr(1),
        \frel.kr(0.2), 1,
        curve:[fatkcurve, fdeccurve, frelcurve]
    ).ar(gate:gate).linlin(0, 1, fenv, 1);
    var res = \res.kr(0.1,
        spec:ControlSpec(0, 1, \lin, 0, 0, "filter")
    ).linlin(0, 1, 0, 4);
    var ffreq = \cutoff.kr(2000) * feg;
    var sig = MoogFF.ar(in, ffreq.clip(20, 20000), gain:res.clip(0.0, 4.0));
    sig = sig * \fcomp.kr(1, spec: ControlSpec(1, 8, \lin, 0, 1, "filter"));
    sig;
}
)