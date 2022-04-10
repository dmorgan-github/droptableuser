(
synth: {|gate, doneAction=(Done.freeSelf)|

    var aeg;
    var atk = \atk.kr(0.01, spec:DMControlSpec(0, 8, \lin, 0, 0.01, units:"aeg", sort:0));
    var dec = \dec.kr(0.1, spec:DMControlSpec(0, 8, \lin, 0, 0.2, units:"aeg", sort:1));
    var sus = \sustain.kr(0.1, spec:DMControlSpec(0, 1, \lin, 0, 0.1, units:"aeg", sort:2));
    var suslevel = \suslevel.kr(0.7, spec:DMControlSpec(0, 1, \lin, 0, 0.7, units:"aeg", sort:3));
    var rel = \rel.kr(1, spec: DMControlSpec(0, 8, \lin, 0, 1, units:"aeg", sort:4));

    var ts = \ts.kr(1);
    var curve = [
        \atkcurve.kr(-4, spec: DMControlSpec(-8, 8, \lin, 0, -4, units:"aeg", sort:5)),
        \deccurve.kr(4, spec: DMControlSpec(-8, 8, \lin, 0, 4, units:"aeg", sort:6)),
        \relcurve.kr(-4, spec: DMControlSpec(-8, 8, \lin, 0, -4, units:"aeg", sort:7))
    ];
    var env = Env([0, 0, 1, suslevel, suslevel, 0], [0, atk, dec, sus, rel], curve:curve);
    aeg = env.ar(doneAction:doneAction, gate:gate + Impulse.kr(0), timeScale:ts);
    aeg;
}
)
