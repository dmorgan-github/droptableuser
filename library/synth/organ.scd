(
synth: {|freq, gate, aeg|

    var harms = [-12, 7, 0, 12, 19, 24, 27, 31, 36].midiratio;

    var controls = harms.collect({|harm, i|

        var n = i + 1;

        var key = ('f' ++ n);

        var partial, atk, suslevel, rel, curve, level, env;

        var num = 2;

        level = key.asSymbol.kr(1/n,
            spec:DMControlSpec(0, 1, \lin, 0, 1/n, units:"organ", sort:(n*num)));

        partial = freq * (key ++ 'ratio').asSymbol.kr(harm,
            spec: DMControlSpec(-24.midiratio, 36.midiratio, \lin, 0, harm, units:"organ", sort:(n*num+1)) );

        /*
        atk = (key ++ 'atk').asSymbol.kr(0.01,
            spec:DMControlSpec(0, 1, \lin, 0, 0.01, units:"organ", sort:(n*num+2)));

        suslevel = (key ++ 'suslevel').asSymbol.kr(1,
            spec:DMControlSpec(0, 1, \lin, 0, 1, units:"organ", sort:(n*num+3)));

        rel = (key ++ 'rel').asSymbol.kr(1,
            spec:DMControlSpec(0, 8, \lin, 0, 0.29, units:"organ", sort:(n*num+4)));

        curve = (key ++ 'curve').asSymbol.kr(-4,
            spec:DMControlSpec(-8, 8, \lin, 0, -4, units:"organ", sort:(n*num+5)));

        env = Env.asr(atk, suslevel, rel, curve).kr(gate:gate) * level;
        */

        [partial, level]
    });

	var sig = DynKlang.ar(`[
        controls.collect({|ctrl| ctrl[0]}),
        controls.collect({|ctrl| ctrl[1]}),
		nil
	]);

    sig * (1/4)

}
)
