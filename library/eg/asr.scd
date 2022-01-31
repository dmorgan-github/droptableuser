(
synth: {|atk=0.01, suslevel=0.7, doneAction=(Done.freeSelf)|
    var gate = \gate.kr;
    var rel = \rel.kr(0.1);
    var ts = \ts.kr(1);
    var curve = [\atkcurve.kr(-4), \deccurve.kr(-4), \relcurve.kr(-4)];
    var env = Env.asr(
        attackTime: \atk.kr(atk),
        sustainLevel: \suslevel.kr(suslevel),
        releaseTime:rel,
        curve:curve
    );
    var aeg = env.ar(doneAction:doneAction, gate:gate, timeScale:ts);
    aeg;
}
)