(
synth: {|freq, gate, aeg|

    var sig1 = SinOscFB.ar(freq, \skew.kr(0));
    var sig2 = Pulse.ar(freq, \pw.kr(0.5));
    var sig3 = Saw.ar(freq);
    var sig4 = VarSaw.ar(freq, 0, \width.kr(0.5));

    var which = \which.kr(0);
    var focus = \focus.kr(1);
    var sig = SelectXFocus.ar(which, [sig1, sig2, sig3, sig4], focus, wrap:true);
    var fenv = 1-\snappy.kr(0.5);
    var fatkcurve = \fatkcurve.kr(-4);
    var frelcurve = \frelcurve.kr(-4);
    var feg =  Env.perc(\fatk.kr(0), \frel.kr(0.2), 1, curve:[fatkcurve, frelcurve]).ar(gate:gate).linlin(0, 1, fenv, 1);
    var res = \res.kr(0.5).linlin(0, 1, 1.4, 0.05);
    var ffreq = \cutoff.kr(2000) * feg;
    sig = RLPF.ar(sig, ffreq.clip(20, 20000), res.clip(0.05, 1.4));
    sig;

}, specs: [
    which: ControlSpec(0, 3, \lin, 0, 1, units: "timbre"),
    focus: ControlSpec(0, 1, \lin, 0, 0.5, units:"timbre"),
    skew: ControlSpec(-1, 1, \lin, 0, 0, units:"timbre"),
    pw: ControlSpec(0, 1, \lin, 0, 0.5, units:"timbre"),
    width: ControlSpec(0, 1, \lin, 0, 0.5, units:"timbre"),
    fatkcurve: ControlSpec(-8, 8, \lin, 0, -4, units:"filter"),
    frelcurve: ControlSpec(-8, 8, \lin, 0, -4, units:"filter"),
    fatk: ControlSpec(0, 1, \lin, 0, 0, units:"filter"),
    snappy: ControlSpec(0, 1, \lin, 0, 0.5, units:"filter"),
]
)