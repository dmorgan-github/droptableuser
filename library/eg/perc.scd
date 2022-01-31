(
synth: {|doneAction=(Done.freeSelf)|
    var atk = \atk.kr(0.01);
    var rel = \rel.kr;
    var ts = \ts.kr(1);
    var curve = [\atkcurve.kr(-4), \relcurve.kr(-4)];
    var env = Env.perc(
        attackTime:atk,
        releaseTime:rel,
        curve:curve
    );
    var aeg = env.ar(doneAction:doneAction, timeScale:ts);
    aeg;
}
)