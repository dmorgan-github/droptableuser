(
synth:{|in, gate, freq, aeg|

    var keyamt = \keyamt.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, "filter"));
    var velamt = ~velamt ?? 0.55;//\velamt.kr(0.55, spec: ControlSpec(0, 1, \lin, 0, 0.55, "filter"));
    var envamt = 1-\envamt.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, "filter"));
    var basefreq = 48.midicps;
    var cutoffratio, sig;

    var fatkcurve = \fatkcurve.kr(-4);
    var fdeccurve = \fdeccurve.kr(-4);
    var frelcurve = \frelcurve.kr(-4);

    var vel = ~vel;
    var cutoff = \cutoff.kr(2000, spec: ControlSpec(20, 20000, \exp, 0, 1000, "filter"));
    var gain = \gain.kr(0,
        spec: ControlSpec(0, 1, \lin, 0, 0, "filter")
    ).linlin(0, 1, 1, 20).clip(1, 20);

    var feg =  Env.adsr(
        \fatk.kr(0),
        \fdec.kr(0.2),
        \fsuslevel.kr(1),
        \frel.kr(0.2), 1,
        curve:[fatkcurve, fdeccurve, frelcurve]
    ).ar(gate:gate).linlin(0, 1, envamt, 1);

    var res = \res.kr(0,
        spec:ControlSpec(0, 1, \lin, 0, 0, "filter")
    ).linlin(0, 1, 0, 4);

    cutoffratio = Select.kr(freq < basefreq, [
        basefreq + ((freq - basefreq) * keyamt),
        basefreq - ((basefreq - freq) * keyamt)
    ]);
    cutoffratio = cutoffratio / basefreq;

    // apply velocity to cutoff
    cutoff = cutoff * (1 + (vel * velamt));
    // apply key tracking
    cutoff = cutoff * cutoffratio;
    // apply envelope
    cutoff = cutoff * feg;

    in = Select.ar(gain > 1, [
        in,
        (in * gain).tanh
    ]);

    sig = MoogFF.ar(in, cutoff.clip(20, 20000), gain:res.clip(0.0, 4.0));
    sig = sig * \fcomp.kr(1, spec: ControlSpec(1, 8, \lin, 0, 1, "filter"));
    sig;
}
)