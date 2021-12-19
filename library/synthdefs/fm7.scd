(
// create synths for each algo
32.do({|i|

    var key = "fm7_algo%".format(i);
    SynthLib.def(key.asSymbol, {|f, g, a|

        var freq = \freq.kr(220);
        var gate = \gate.kr(1);
        var fb = \fb.kr(0);
        var algo = i;
        var ops = 6.collect({|i|
            var num = i + 1;
            var units = "op" ++ num;
            var ratio = ('op' ++ num ++ 'ratio').asSymbol.kr(1, spec: ControlSpec(1/8, 31, \lin, 0.01, 1, units: units) );
            var atk = ('op' ++ num ++ 'atk').asSymbol.kr(1, spec: ControlSpec(0, 2, \lin, 0, 0.01, units: units) );
            var dec = ('op' ++ num ++ 'dec').asSymbol.kr(1, spec: ControlSpec(0, 1, \lin, 0, 0.2, units: units) );
            var rel = ('op' ++ num ++ 'rel').asSymbol.kr(0.5, spec: ControlSpec(0, 8, \lin, 0, 0.5, units: units) );
            var suslevel = ('op' ++ num ++ 'suslevel').asSymbol.kr(0.7, spec: ControlSpec(0, 1, \lin, 0, 0.7, units: units) );
            var peak = ('op' ++ num ++ 'peak').asSymbol.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units: units) );
            var atkcurve = ('op' ++ num ++ 'atkcurve').asSymbol.kr(-4, spec: ControlSpec(-8, 8, \lin, 0, -4, units: units) );
            var deccurve = ('op' ++ num ++ 'deccurve').asSymbol.kr(-4, spec: ControlSpec(-8, 8, \lin, 0, -4, units: units) );
            var relcurve = ('op' ++ num ++ 'relcurve').asSymbol.kr(-4, spec: ControlSpec(-8, 8, \lin, 0, -4, units: units) );

            var env = Env.adsr(atk, dec, suslevel, rel, peakLevel: peak,
                curve:[atkcurve, deccurve, relcurve]
            ).ar(gate:gate);
            [freq * ratio, 0, env * units.asSymbol.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units: units))];
        });

        var sig = FM7.arAlgo(algo, ops, fb);
        sig = sig.asArray.flatten.sum;

        DetectSilence.ar(sig, doneAction:Done.freeSelf);

        sig;

    }, template:'slim', specs: [
            'matk', ControlSpec(0, 2, \lin, 0, 1, units: "menv"),
            'mdec', ControlSpec(0, 2, \lin, 0, 1, units: "menv"),
            'mrel', ControlSpec(0, 2, \lin, 0, 1, units: "menv"),
            'msuslevel', ControlSpec(0, 1, \lin, 0, 1, units: "menv"),
            'mpeak', ControlSpec(0, 1, \lin, 0, 1, units: "menv")
        ]
    );
});

)
