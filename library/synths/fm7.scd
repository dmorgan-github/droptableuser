(
var func = {|freq, gate, aeg|

	var ops = 6.collect({|i|
		var num = i + 1;
		var ratio = ('op' ++ num ++ 'ratio').asSymbol.kr(1);
		var atk = ('op' ++ num ++ 'atk').asSymbol.kr(1) * \atk.kr;
		var dec = ('op' ++ num ++ 'dec').asSymbol.kr(1) * \dec.kr;
		var rel = ('op' ++ num ++ 'rel').asSymbol.kr(1) * \rel.kr;
		var suslevel = ('op' ++ num ++ 'suslevel').asSymbol.kr(1) * \suslevel.kr;
		var curve = ('op' ++ num ++ 'curve').asSymbol.kr(-4);
		var env = Env.adsr(atk, dec, suslevel, rel, curve:curve).ar(gate:gate);
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

S.def(\fm7, func);
S.def(\fm7_mono, func, \mono);

// create synths for each algo
32.do({|i|

	var key = "fm7_algo%".format(i + 1);
	S.def(key.asSymbol, {|freq, gate, aeg|

		var fb = \fb.kr(0);
		var algo = i;
		var ops = 6.collect({|i|
			var num = i + 1;
			var ratio = ('op' ++ num ++ 'ratio').asSymbol.kr(1);
			var atk = ('op' ++ num ++ 'atk').asSymbol.kr(1) * \atk.kr;
			var dec = ('op' ++ num ++ 'dec').asSymbol.kr(1) * \dec.kr;
			var rel = ('op' ++ num ++ 'rel').asSymbol.kr(1) * \rel.kr;
			var suslevel = ('op' ++ num ++ 'suslevel').asSymbol.kr(1) * \suslevel.kr;
			var curve = ('op' ++ num ++ 'curve').asSymbol.kr(-4);
			var env = Env.adsr(atk, dec, suslevel, rel, curve:curve).ar(gate:gate);
			[freq[0] * ratio, 0, env];
		});

		var sig = FM7.arAlgo(algo, ops, fb);
		sig;
	});

	// using a trigger instead of gate for mono synth
	// and \sustain calculated from lang side for the duration
	// so it is a slightly different function
	key = "fm7_algo%_mono".format(i + 1);
	S.def(key.asSymbol, {|freq, gate, aeg|

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
			var curve = ('op' ++ num ++ 'curve').asSymbol.kr(-4);
			var env = Env(
				[0, 1, suslevel, suslevel, 0],
				[atk, dec, sus, rel],
				curve:curve
			).ar(doneAction:Done.none, gate:gate);

			[freq[0] * ratio, 0, env];
		});

		var sig = FM7.arAlgo(algo, ops, fb);
		sig;
	}, \mono);

});

)
