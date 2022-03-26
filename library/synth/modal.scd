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
    ).linlin(0, 1, 80, 16000);

    var morph, sig;

    //var exciter = ~exciter ?? { Impulse.ar(0) };

    //var exciter = ~exciter ?? { Hasher.ar(Sweep.ar) * Env.perc(0, 0.01).ar };

    var exciter = ~exciter ?? { WhiteNoise.ar * Env.perc(0, 0.01).ar * 0.7 };

    exciter = exciter * 0.2;

    //var exciter = ~exciter ?? { PinkNoise.ar * Env.perc(0, 0.001).ar };

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



