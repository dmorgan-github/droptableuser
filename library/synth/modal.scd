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

    var noisedecay = \noisedecay.kr(0.01, spec:ControlSpec(0.001, 1, \lin, 0, 0.01, units:"modal"));

    var vol = noisedecay.linlin(0, 1, 1, 2).sqrt.reciprocal;

    var exciter = ~exciter ?? { BrownNoise.ar * Env.perc(0.05, noisedecay).ar(gate:gate) * 0.2 * vol };

    exciter = exciter * 0.2;

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



