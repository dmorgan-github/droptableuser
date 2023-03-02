(
synth: {|gate, doneAction=(Done.freeSelf)|

    var aeg, env;
    var atk = \atk.kr(0.01, spec:DMControlSpec(0, 8, \lin, 0, 0.01, units:"aeg", sort:0));
    var dec = \dec.kr(0.2, spec:DMControlSpec(0, 1, \lin, 0, 0.2, units:"aeg", sort:1));
    var suslevel = \suslevel.kr(0.7, spec:DMControlSpec(0, 1, \lin, 0, 0.7, units:"aeg", sort:2));
    var rel = \rel.kr(1, spec: DMControlSpec(0, 8, \lin, 0, 1, units:"aeg", sort:3));

    var ts = \ts.kr(1);
    var curve = [
        \atkcurve.kr(-4, spec: DMControlSpec(-8, 8, \lin, 0, -4, units:"aeg", sort:4)),
        \deccurve.kr(-4, spec: DMControlSpec(-8, 8, \lin, 0, -4, units:"aeg", sort:5)),
        \relcurve.kr(-4, spec: DMControlSpec(-8, 8, \lin, 0, -4, units:"aeg", sort:6))
    ];

    if (~gatemode.debug("gate mode") == \retrig) {
        var sus = \sustain.kr(0.1, spec:DMControlSpec(0, 1, \lin, 0, 0.1, units:"aeg", sort:2));
        env = Env([0, 0, 1, suslevel, suslevel, 0], [0, atk, dec, sus, rel], curve:curve);
    }{
        env = Env.adsr(
            attackTime:atk,
            decayTime:dec,
            sustainLevel:suslevel,
            releaseTime:rel,
            curve:curve
        );
    };

    //aeg = env.ar(doneAction:doneAction, gate:gate + Impulse.kr(0), timeScale:ts);
    aeg = env.ar(doneAction:doneAction, gate:gate, timeScale:ts);
    aeg;
}
)
