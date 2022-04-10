(
synth: {|in, gate, freq|

    var velamt = ~velamt ?? 0.55;
    var vel = ~vel;
    /*
    0 = LPF2
    1 = LPF4
    2 = BPF2
    3 = BPF4
    4 = HPF2
    5 = HPF4
    */
    var type = \type.kr(1, spec: DMControlSpec(0, 5, \lin, 1, 1, units:"filter", sort:0));

    var keyamt = \keyamt.kr(0, spec: DMControlSpec(0, 1, \lin, 0, 0, "filter", sort:8));
    var cutoff = \cutoff.kr(2000, spec: DMControlSpec(20, 20000, \exp, 0, 1000, "filter", sort:9));
    var res = \res.kr(0.1, spec:DMControlSpec(0, 1, \lin, 0, 0.1, units:"filter", sort:10));
    var basefreq = 48.midicps;
    var cutoffratio;

    var fatkcurve = \fatkcurve.kr(-4, spec: DMControlSpec(-8, 8, \lin, 0, -4, units:"filter", sort:5));
    var fdeccurve = \fdeccurve.kr(-4, spec: DMControlSpec(-8, 8, \lin, 0, -4, units:"filter", sort:6));
    var frelcurve = \frelcurve.kr(-4, spec: DMControlSpec(-8, 8, \lin, 0, -4, units:"filter", sort:7));

    var feg = Env.adsr(
        \fatk.kr(0, spec: DMControlSpec(0, 1, \lin, 0, 0.01, units:"filter", sort:1)),
        \fdec.kr(0.2, spec: DMControlSpec(0, 1, \lin, 0, 0.2, units:"filter", sort:2)),
        \fsuslevel.kr(1, spec: DMControlSpec(0, 1, \lin, 0, 1, units:"filter", sort:3)),
        \frel.kr(0.2, spec: DMControlSpec(0, 8, \lin, 0, 0.29, units:"filter", sort:4)),
        1,
        curve:[fatkcurve, fdeccurve, frelcurve]
    ).ar(gate:gate);//.linlin(0, 1, 1, 0.1);

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

    cutoff = cutoff.clip(20, 20000);

    VadimFilter.ar(in, cutoff, res, type);
}
)