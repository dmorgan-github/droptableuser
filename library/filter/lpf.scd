(
synth:{|in, gate, freq, aeg|

    var type = ~type ?? \rlpf;
    var velamt = ~velamt ?? 0.55;
    var vel = ~vel;
    var keyamt = \keyamt.kr(0, spec: ControlSpec(0, 1, \lin, 0, 0, "filter"));
    var envamt = 1-\envdepth.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, "filter"));
    var basefreq = 48.midicps;
    var cutoffratio, sig;

    var fatkcurve = \fatkcurve.kr(-4, spec: DMControlSpec(-8, 8, \lin, 0, -4, units:"filter", sort:4));
    var fdeccurve = \fdeccurve.kr(-4, spec: DMControlSpec(-8, 8, \lin, 0, -4, units:"filter", sort:5));
    var frelcurve = \frelcurve.kr(-4, spec: DMControlSpec(-8, 8, \lin, 0, -4, units:"filter", sort:6));
    var cutoff = \cutoff.kr(2000, spec: ControlSpec(20, 20000, \exp, 0, 1000, "filter"));

    var feg = Env.adsr(
        \fatk.kr(0, spec: DMControlSpec(0, 1, \lin, 0, 0.01, units:"filter", sort:0)),
        \fdec.kr(0.2, spec: DMControlSpec(0, 1, \lin, 0, 0.2, units:"filter", sort:1)),
        \fsuslevel.kr(1, spec: DMControlSpec(0, 1, \lin, 0, 1, units:"filter", sort:2)),
        \frel.kr(0.2, spec: DMControlSpec(0, 8, \lin, 0, 0.29, units:"filter", sort:3)),
        1,
        curve:[fatkcurve, fdeccurve, frelcurve]
    ).ar(gate:gate).linlin(0, 1, envamt, 1);

    var res = \res.kr(0,
        spec:ControlSpec(0, 1, \lin, 0, 0, "filter")
    );

    var lforate = \cutofflforate.kr(0, spec: ControlSpec(0, 20, \lin, 0, 0, "filter"));
    var lfodepth = \cutofflfodepth.kr(0, spec: ControlSpec(0, 12, \lin, 0, 0, "filter"));
    var lfo = ~lfo.(lforate, lfodepth);

    if (lfo.isNil) {
        lfo = SinOsc.ar(lforate).unipolar(lfodepth);
    };

    cutoffratio = Select.kr(freq < basefreq, [
        basefreq + ((freq - basefreq) * keyamt),
        basefreq - ((basefreq - freq) * keyamt)
    ]);
    cutoffratio = cutoffratio / basefreq;

    // apply velocity to cutoff
    cutoff = cutoff * (1 + (vel * velamt));
    // apply key tracking
    cutoff = cutoff * cutoffratio;
    // apply lfo
    cutoff = cutoff * (1+lfo);
    // apply envelope
    cutoff = cutoff * feg;

    cutoff = cutoff.clip(20, 20000);

    sig = switch(type,
        'dfm1', {
            \dfm1.debug("filter");
            res = res.linlin(0, 1, 0, 1.4);
            DFM1.ar(in, cutoff, res.clip(0.0, 1.4))
        },
        'moogff', {
            \moogff.debug("filter");
            res = res.linlin(0, 1, 0, 4);
            MoogFF.ar(in, cutoff, gain:res.clip(0.0, 4.0))
        },
        '12db', {
            '12db'.debug("filter");
            res = res.linlin(0, 1, 1.4, 0.05);
            BLowPass.ar(in, cutoff, rq:res.clip(0.05, 1.4));
        },
        '24db', {
            '24db'.debug("filter");
            res = res.linlin(0, 1, 1.4, 0.05);
            BLowPass4.ar(in, cutoff, rq:res.clip(0.05, 1.4));
        },
        {
            \rlpf.debug("filter");
            res = res.linlin(0, 1, 1.4, 0.05);
            RLPF.ar(in, cutoff, res.clip(0.05, 1.4))
        }
    );

    sig = sig * \fcomp.kr(1, spec: ControlSpec(1, 8, \lin, 0, 1, "filter"));
    sig;
}
)