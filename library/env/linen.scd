(
synth: {|gate, doneAction=(Done.freeSelf)|

    var atk = \atk.kr(0.01, spec:DMControlSpec(0, 8, \lin, 0, 0.01, units:"aeg", sort:0));
    var sus = \sustain.kr(1, spec: DMControlSpec(0, 8, \lin, 0, 1, units:"aeg", sort:1));
    var rel = \rel.kr(0.1, spec: DMControlSpec(0, 8, \lin, 0, 0.1, units:"aeg", sort:3));

    var ts = \ts.kr(1);
    var curve = [
        \atkcurve.kr(-4, spec:DMControlSpec(-8, 8, \lin, 0, -4, units:"aeg", sort:4)),
        \relcurve.kr(-4, spec: DMControlSpec(-8, 8, \lin, 0, -4, units:"aeg", sort:6))
    ];
    var env = Env.linen(
        attackTime:atk,
        sustainTime:sus,
        releaseTime:rel,
        curve:curve
    );
    var aeg = env.ar(gate: gate, doneAction:doneAction, timeScale:ts);
    aeg;
},
props: (
    hasgate: false
)
)