(
synth: {|gate, doneAction=(Done.freeSelf)|
    var atk = \atk.kr(0.01);
    var dec = \dec.kr(0.1);
    var rel = \rel.kr(1);
    var suslevel = \suslevel.kr(0.7);
    var ts = \ts.kr(1);
    var curve = [\atkcurve.kr(-4), \deccurve.kr(-4), \relcurve.kr(-4)];
    var env = Env.adsr(
        attackTime:atk,
        decayTime:dec,
        sustainLevel:suslevel,
        releaseTime:rel,
        curve:curve
    );
    var aeg = env.ar(doneAction:doneAction, gate:gate, timeScale:ts);
    aeg;
}
)