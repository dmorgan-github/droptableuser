(
synth: {|freq, gate, aeg|

    var mod = {
        var ratio = \modratio.kr(1, spec:ControlSpec(0.5, 20, \lin, 0, 1, units:"mod"));
        var fb = \modfb.kr(0, spec:ControlSpec(0, 1.5, \lin, 0, 0, units:"mod"));
        var atk = \matk.kr(0.01, spec:ControlSpec(0, 2, \lin, 0, 0.01, units:"mod"));
        var dec = \mdec.kr(0.3, spec:ControlSpec(0, 2, \lin, 0, 0.3, units:"mod"));
        var rel = \mrel.kr(0.2, spec:ControlSpec(0, 8, \lin, 0, 0.2, units:"mod"));
        var suslevel = \msuslevel.kr(1, spec:ControlSpec(0, 1, \lin, 0, 0.7, units:"mod"));
        var peak = \mpeak.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, units:"mod"));
        var atkcurve = \matkcurve.kr(-4, spec:ControlSpec(-8, 8, \lin, 0, -4, units:"mod"));
        var deccurve = \mdeccurve.kr(-4, spec:ControlSpec(-8, 8, \lin, 0, -4, units:"mod"));
        var relcurve = \mrelcurve.kr(-4, spec:ControlSpec(-8, 8, \lin, 0, -4, units:"mod"));
        var bias = \mbias.kr(0, spec:ControlSpec(0, 4, \lin, 0, 0, units:"mod"));
        var meg = Env.adsr(
            atk,
            dec,
            suslevel,
            rel,
            peak,
            curve:[atkcurve, deccurve, relcurve],
            bias: bias
        ).ar(gate:gate);

        var index = \mindex.kr(0, spec:ControlSpec(0, 20, \lin, 0, 0, units:"mod"));
        var sig = SinOscFB.ar(freq * ratio, fb);

        sig = sig * meg * index;
        sig;
    };
    var carratio = \carratio.kr(1, spec:ControlSpec(0.5, 20, \lin, 0, 1, units:"car"));
    var sig = SinOsc.ar(freq * carratio, mod.().mod(2pi));
    sig// * \mindex.kr.sqrt.reciprocal
}
)