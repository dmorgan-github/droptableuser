(
synth: {|freq|

    var algo = ~algo ?? 0;
    var fb = \fb.kr(0);

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
        ).ar(gate: 1);

        [freq.asArray[0] * ratio, 0, env * units.asSymbol.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units: units))];
    });

    var sig = FM7.arAlgo(algo.debug("algo"), ops, fb);
    sig;
}
)
