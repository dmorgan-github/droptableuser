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
		var vel = \fvel.kr(2);
		var res = \res.kr(0.1).linlin(0, 1, 1, 0.00001);
		var ffreq = Env(
			[1, vel, vel * suslevel, vel * suslevel, 1],
			[atk, dec, sus, rel],
			[curve1,curve2,curve3]
		).kr(gate:\trig.tr) * cutoff;
		BBandPass.ar(in, ffreq.clip(20, 20000), res);
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
		var vel = \fvel.kr(2);
		var res = \res.kr(0.1);
		var ffreq = Env(
			[1, vel, vel * suslevel, vel * suslevel, 1],
			[atk, dec, sus, rel],
			[curve1,curve2,curve3]
		).kr(gate:\trig.tr) * cutoff;
		DFM1.ar(in, ffreq.clip(20, 20000), res);
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
		var vel = \fvel.kr(2);
		var res = \res.kr(0.1).linlin(0, 1, 1, 0.00001);
		var ffreq = Env(
			[1, vel, vel * suslevel, vel * suslevel, 1],
			[atk, dec, sus, rel],
			[curve1,curve2,curve3]
		).kr(gate:\trig.tr) * cutoff;
		BLowPass4.ar(in, ffreq.clip(20, 20000), res);
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
		var vel = \fvel.kr(2);
		var res = \res.kr(0.1).linlin(0, 1, 1, 0.00001);
		var ffreq = Env(
			[1, vel, vel * suslevel, vel * suslevel, 1],
			[atk, dec, sus, rel],
			[curve1,curve2,curve3]
		).kr(gate:\trig.tr) * cutoff;
		BHiPass4.ar(in, ffreq.clip(20, 20000), res);
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
		var vel = \fvel.kr(2);
		var res = \res.kr(0.1).linlin(0, 1, 1, 0.00001);
		var ffreq = Env(
			[1, vel, vel * suslevel, vel * suslevel, 1],
			[atk, dec, sus, rel],
			[curve1,curve2,curve3]
		).kr(gate:\trig.tr) * cutoff;
		RLPF.ar(in, ffreq.clip(20, 20000), res);
	}
});

Library.put(\fx, \squiz, {
	{arg in;
		Squiz.ar(in, [\prL.kr(1.5), \prR.kr(2)], \zcp.kr(1));
	}
});

Library.put(\fx, \pitchshift, {arg windowSize=0.2;
	"pitchshift windowsize: %".format(windowSize).debug(\pitchshift);
	{arg in;
		PitchShift.ar(in, windowSize, [\prL.kr(1), \prR.kr(2)], \pitchDispersion.kr(0.01), \timeDispersion.kr(0.01));
	}
});

Library.put(\fx, \greyhole, {
	{arg in;
		Greyhole.ar(in,
			\ghdelayTime.kr(2.0),
			\ghdamp.kr(0),
			\ghsize.kr(1.0),
			\ghdiff.kr(0.707),
			\ghfeedback.kr(0.9),
			\ghmodDepth.kr(0.1),
			\ghmodFreq.kr(2.0)
		);
	}
});

Library.put(\fx, \waveloss, {
	{arg in;
		WaveLoss.ar(in, [\dropL.kr(20), \dropR.kr(20)], \outof.kr(40), \mode.kr(1));
	}
});

)