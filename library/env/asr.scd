(
synth: {|gate, doneAction=(Done.freeSelf)|
    var rel = \rel.kr(0.1);
    var ts = \ts.kr(1);
    var curve = [\atkcurve.kr(-4), \relcurve.kr(-4)];
    var env = Env.asr(
        attackTime: \atk.kr(0.01),
        sustainLevel: \suslevel.kr(0.7),
        releaseTime:rel,
        curve:curve
    );
    var aeg = env.ar(doneAction:doneAction, gate:gate, timeScale:ts);
    aeg;
}
)