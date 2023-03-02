(
synth: {|gate, doneAction=(Done.freeSelf)|

    var env, aeg;
    var atk = \atk.kr(0.01, spec:DMControlSpec(0, 8, \lin, 0, 0.01, units:"aeg", sort:0));
    var suslevel = \suslevel.kr(1, spec:DMControlSpec(0, 1, \lin, 0, 1, units:"aeg", sort:2));
    var rel = \rel.kr(1, spec: DMControlSpec(0, 8, \lin, 0, 1, units:"aeg", sort:3));

    var ts = \ts.kr(1);
    var curve = [
        \atkcurve.kr(-4, spec:DMControlSpec(-8, 8, \lin, 0, -4, units:"aeg", sort:4)),
        \relcurve.kr(-4, spec: DMControlSpec(-8, 8, \lin, 0, -4, units:"aeg", sort:6))
    ];

    if (~gatemode == \retrig) {
        var sus = \sustain.kr(0.1, spec:DMControlSpec(0, 1, \lin, 0, 0.1, units:"aeg", sort:2));
        env = Env([0, suslevel, suslevel, 0], [atk, sus, rel], curve:curve);
    }{
        env = Env.asr(
            attackTime: atk,
            sustainLevel: suslevel,
            releaseTime:rel,
            curve:curve
        );
    };

    //aeg = env.ar(doneAction:doneAction, gate:gate + Impulse.kr(0), timeScale:ts);
    aeg = env.ar(doneAction:doneAction, gate:gate, timeScale:ts);
    aeg;
}
)
