(
synth: {|freq, gate, aeg|

    var mod = {
        var ratio = \modratio.kr(1);
        var fb = \modfb.kr(0);
        var sig = SinOscFB.ar(freq * ratio, fb);
        var atk = \matk.kr(0.01);
        var dec = \mdec.kr(0.3);
        var rel = \mrel.kr(0.2);
        var suslevel = \msuslevel.kr(1);
        var peak = \mpeak.kr(1);
        var atkcurve = \matkcurve.kr(-4);
        var deccurve = \mdeccurve.kr(-4);
        var relcurve = \mrelcurve.kr(-4);
        var bias = \mbias.kr(0);
        var meg = Env.adsr(
            atk,
            dec,
            suslevel,
            rel,
            peak,
            curve:[atkcurve, deccurve, relcurve],
            bias: bias
        ).ar(gate:gate);
        var index = \mindex.kr(0);

        sig = sig * meg * index;
        sig;
    };
    var sig = SinOsc.ar(freq * \carratio.kr(1), mod.().mod(2pi));
    sig// * \mindex.kr.sqrt.reciprocal

}, specs: [
    carratio: ControlSpec(0.5, 20, \lin, 0, 1, units:"car"),
    modratio: ControlSpec(0.5, 20, \lin, 0, 1, units:"mod"),
    modfb: ControlSpec(0, 1, \lin, 0, 0, units:"mod"),
    matk: ControlSpec(0, 1, \lin, 0, 0.01, units:"mod"),
    mdec: ControlSpec(0, 1, \lin, 0, 0.3, units:"mod"),
    mrel: ControlSpec(0, 8, \lin, 0, 0.2, units:"mod"),
    msuslevel: ControlSpec(0, 1, \lin, 0, 0.7, units:"mod"),
    mpeak: ControlSpec(0, 1, \lin, 0, 0.7, units:"mod"),
    mbias: ControlSpec(0, 4, \lin, 0, 0, units:"mod"),
    matkcurve: ControlSpec(-8, 8, \lin, 0, -4, units:"mod"),
    mdeccurve: ControlSpec(-8, 8, \lin, 0, -4, units:"mod"),
    mrelcurve: ControlSpec(-8, 8, \lin, 0, -4, units:"mod"),
    mindex: ControlSpec(0, 20, \lin, 0, 0, units:"mod")
]
)