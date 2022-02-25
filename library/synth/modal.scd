(
synth: {|freq, gate, aeg|

    var numharms = ~numharms ?? 8;
    var harm = \harm.kr(0, spec: ControlSpec(-0.06, 2, \lin, 0, 0, units:"modal"));
    var k = (1..8);
    var ratio = {
        var val = k * (1 + ((k-1) * harm));
        val/val[0];
    }.();

    var bright = \bright.kr(0.5,
        spec: ControlSpec(0.0, 1.0, \lin, 0, 0.5, units:"modal")
    ).linlin(0, 1, 80, 8000);

    var morph, sig;

    var exciter = ~exciter ?? { Impulse.ar(0) };

    exciter = LPF.ar(exciter, bright);

    morph = \morph.kr(0.0,
        spec: ControlSpec(0.0, 1.0, \lin, 0, 0, units:"modal")
    ).linlin(0, 1, 1, 100);

    sig = DynKlank.ar(`[
        ratio,
        (k * -3).dbamp,
        ratio.squared.reciprocal * 5;
    ], exciter, freq, decayscale: morph);

    sig
},
credit: "adapted from formula by Nathan Ho"
)



