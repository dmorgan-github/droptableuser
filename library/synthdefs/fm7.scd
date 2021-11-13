(
/*
var func = {|freq, gate, aeg|

	var ops = 6.collect({|i|
		var num = i + 1;
		var ratio = ('op' ++ num ++ 'ratio').asSymbol.kr(1);
		var atk = ('op' ++ num ++ 'atk').asSymbol.kr(1) * \atk.kr;
		var dec = ('op' ++ num ++ 'dec').asSymbol.kr(1) * \dec.kr;
		var rel = ('op' ++ num ++ 'rel').asSymbol.kr(1) * \rel.kr;
		var suslevel = ('op' ++ num ++ 'suslevel').asSymbol.kr(1) * \suslevel.kr;
		var peak = ('op' ++ num ++ 'peak').asSymbol.kr(1);
		var curve = ('op' ++ num ++ 'curve').asSymbol.kr(-4);
		var env = Env.adsr(atk, dec, suslevel, rel, peakLevel:peak, curve:curve).ar(gate:gate);
		[freq[0] * ratio, 0, env];
	});

	var mods = 6.collect({|i|
		var row = i + 1;
		6.collect({|j|
			var col = j + 1;
			var key = ('m' ++ row ++ '_' ++ col).asSymbol.kr(0);
			key;
		});
	});

	var amps = 6.collect({|i|
		var num = i + 1;
		var key = ('op' ++ num).asSymbol.kr(0);
		key
	});

	var sig = FM7.ar(ops, mods) * amps;
	sig.sum;
};

SynthLib.def(\fm7, func);
SynthLib.def(\fm7_mono, func, \mono);
*/

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
            var ratio = ('op' ++ num ++ 'ratio').asSymbol.kr(1);
            var atk = ('op' ++ num ++ 'atk').asSymbol.kr(1);
            var dec = ('op' ++ num ++ 'dec').asSymbol.kr(1);
            var rel = ('op' ++ num ++ 'rel').asSymbol.kr(1);
            var suslevel = ('op' ++ num ++ 'suslevel').asSymbol.kr(1);
            var peak = ('op' ++ num ++ 'peak').asSymbol.kr(1);
            var atkcurve = ('op' ++ num ++ 'atkcurve').asSymbol.kr(-4);
            var deccurve = ('op' ++ num ++ 'deccurve').asSymbol.kr(-4);
            var relcurve = ('op' ++ num ++ 'relcurve').asSymbol.kr(-4);

            var env = Env.adsr(atk, dec, suslevel, rel, peakLevel: peak,
                curve:[atkcurve, deccurve, relcurve]).ar(gate:gate);
            [freq * ratio, 0, env];
        });

        var sig = FM7.arAlgo(algo, ops, fb);
        sig = sig.asArray.flatten.sum;

        DetectSilence.ar(sig, doneAction:Done.freeSelf);

        sig;

    }, template:'slim', specs: 6.collect({|i|
        var num = i+1;
        var units = "op" ++ num;
        [
            ('op' ++ num ++ 'ratio').asSymbol, ControlSpec(1/8, 12, \lin, 0.01, 1, units: units),
            ('op' ++ num ++ 'atk').asSymbol, ControlSpec(0, 2, \lin, 0, 0.01, units: units),
            ('op' ++ num ++ 'dec').asSymbol, ControlSpec(0, 1, \lin, 0, 0.2, units: units),
            ('op' ++ num ++ 'rel').asSymbol, ControlSpec(0, 8, \lin, 0, 0.29, units: units),
            ('op' ++ num ++ 'suslevel').asSymbol, ControlSpec(0, 1, \lin, 0, 1, units: units),
            ('op' ++ num ++ 'peak').asSymbol, ControlSpec(0, 1, \lin, 0, 1, units: units),
            ('op' ++ num ++ 'atkcurve').asSymbol, ControlSpec(-8, 8, \lin, 0, -4, units: units),
            ('op' ++ num ++ 'deccurve').asSymbol, ControlSpec(-8, 8, \lin, 0, -4, units: units),
            ('op' ++ num ++ 'relcurve').asSymbol, ControlSpec(-8, 8, \lin, 0, -4, units: units)
        ]
    }).flatten
    );

    /*
	// using a trigger instead of gate for mono synth
	// and \sustain calculated from lang side for the duration
	// so it is a slightly different function
	key = "fm7_algo%_mono".format(i);
	SynthLib.def(key.asSymbol, {|freq, gate, aeg|

		var fb = \fb.kr(0);
		var algo = i;
		var ops = 6.collect({|i|
			var num = i + 1;
			var ratio = ('op' ++ num ++ 'ratio').asSymbol.kr(1);
			var atk = ('op' ++ num ++ 'atk').asSymbol.kr(1) * \atk.kr;
			var dec = ('op' ++ num ++ 'dec').asSymbol.kr(1) * \dec.kr;
			var rel = ('op' ++ num ++ 'rel').asSymbol.kr(1) * \rel.kr;
			var suslevel = ('op' ++ num ++ 'suslevel').asSymbol.kr(1) * \suslevel.kr;
			var sus = ('op' ++ num ++ 'sus').asSymbol.kr(1) * \sustain.kr;
			var peak = ('op' ++ num ++ 'peak').asSymbol.kr(1);
			var curve = ('op' ++ num ++ 'curve').asSymbol.kr(-4);
			var env = Env(
				[0, peak, suslevel, suslevel, 0],
				[atk, dec, sus, rel],
				curve:curve
			).ar(doneAction:Done.none, gate:gate);

			[freq[0] * ratio, 0, env];
		});

		var sig = FM7.arAlgo(algo, ops, fb);
		sig;
	}, \mono);
    */

});

)
