(
Library.put(\fx, \delay, {arg maxdelay=1;
	{arg in;
		in = LPF.ar(HPF.ar(in, \delhi.kr(20)), \dello.kr(20000));
		FbC({arg fb; fb.reverse * [\fbL.kr(0.2), \fbR.kr(0.3)] + in;},
			maxdelay,
			\beatdur.kr(1) * [\delL.kr(3/4), \delR.kr(5/8)]
		);
	};
});

Library.put(\fx, \reverb, {
	{arg in;
		in = LPF.ar(HPF.ar(in, \revhi.kr(20)), \revlo.kr(20000));
		JPverb.ar(in, \t60.kr(1), 0,
			\size.kr(1),
			\earlyDiff.kr(0.707),
			\modDepth.kr(0.1),
			\modFreq.kr(2.0)
		);
	}
});

Library.put(\fx, \bandpass, {
	{arg in;
		var suslevel = \fsuslevel.kr(0.5);
		var atk = \fatk.kr(0.001);
		var dec = \fdec.kr(0);
		var sus = \fsus.kr(0);
		var rel = \frel.kr(1);
		var curve1 = \fcurve1.kr(-4);
		var curve2 = \fcurve2.kr(-4);
		var curve3 = \fcurve3.kr(-4);
		var cutoff = \cutoff.kr(1000);
		var vel = \fvel.kr(1);
		var res = \res.kr(0.1).linlin(0, 1, 1, 0.00001);
		var ffreq = Env(
			[0, 1, suslevel, suslevel, 0],
			[atk, dec, sus, rel],
			[curve1,curve2,curve3]
		).kr(gate:\trig.tr).range(cutoff, cutoff * vel).clip(20, 20000);
		BBandPass.ar(in, ffreq, res);
	}
});

Library.put(\fx, \dfm1, {
	{arg in;
		var suslevel = \fsuslevel.kr(0.5);
		var atk = \fatk.kr(0.001);
		var dec = \fdec.kr(0);
		var sus = \fsus.kr(0);
		var rel = \frel.kr(1);
		var curve1 = \fcurve1.kr(-4);
		var curve2 = \fcurve2.kr(-4);
		var curve3 = \fcurve3.kr(-4);
		var cutoff = \cutoff.kr(1000);
		var vel = \fvel.kr(1);
		var res = \res.kr(0.1);
		var ffreq = Env(
			[0, 1, suslevel, suslevel, 0],
			[atk, dec, sus, rel],
			[curve1,curve2,curve3]
		).kr(gate:\trig.tr).range(cutoff, cutoff * vel).clip(20, 20000);
		DFM1.ar(in, ffreq, res);
	}
});

Library.put(\fx, \lopass4, {
	{arg in;
		var suslevel = \fsuslevel.kr(0.5);
		var atk = \fatk.kr(0.001);
		var dec = \fdec.kr(0);
		var sus = \fsus.kr(0);
		var rel = \frel.kr(1);
		var curve1 = \fcurve1.kr(-4);
		var curve2 = \fcurve2.kr(-4);
		var curve3 = \fcurve3.kr(-4);
		var cutoff = \cutoff.kr(1000);
		var vel = \fvel.kr(1);
		var res = \res.kr(0.1).linlin(0, 1, 1, 0.00001);
		var ffreq = Env(
			[0, 1, suslevel, suslevel, 0],
			[atk, dec, sus, rel],
			[curve1,curve2,curve3]
		).kr(gate:\trig.tr).range(cutoff, cutoff * vel).clip(20, 20000);
		BLowPass4.ar(in, ffreq, res);
	}
});

Library.put(\fx, \hipass4, {
	{arg in;
		var suslevel = \fsuslevel.kr(0.5);
		var atk = \fatk.kr(0.001);
		var dec = \fdec.kr(0);
		var sus = \fsus.kr(0);
		var rel = \frel.kr(1);
		var curve1 = \fcurve1.kr(-4);
		var curve2 = \fcurve2.kr(-4);
		var curve3 = \fcurve3.kr(-4);
		var cutoff = \cutoff.kr(1000);
		var vel = \fvel.kr(1);
		var res = \res.kr(0.1).linlin(0, 1, 1, 0.00001);
		var ffreq = Env(
			[0, 1, suslevel, suslevel, 0],
			[atk, dec, sus, rel],
			[curve1,curve2,curve3]
		).kr(gate:\trig.tr).range(cutoff, cutoff * vel).clip(20, 20000);
		BHiPass4.ar(in, ffreq, res);
	}
});

Library.put(\fx, \rlpf, {
	{arg in;
		var suslevel = \fsuslevel.kr(0.5);
		var atk = \fatk.kr(0.001);
		var dec = \fdec.kr(0);
		var sus = \fsus.kr(0);
		var rel = \frel.kr(1);
		var curve1 = \fcurve1.kr(-4);
		var curve2 = \fcurve2.kr(-4);
		var curve3 = \fcurve3.kr(-4);
		var cutoff = \cutoff.kr(1000);
		var vel = \fvel.kr(1);
		var res = \res.kr(0.1).linlin(0, 1, 1, 0.00001);
		var ffreq = Env(
			[0, 1, suslevel, suslevel, 0],
			[atk, dec, sus, rel],
			[curve1,curve2,curve3]
		).kr(gate:\trig.tr).range(cutoff, cutoff * vel).clip(20, 20000);
		RLPF.ar(in, ffreq, res);
	}
});

)