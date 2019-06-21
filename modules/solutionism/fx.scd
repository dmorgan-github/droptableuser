(
Library.put(\fx, \compressor, {
	{arg in;
		var sig = CompanderD.ar(in: in, thresh: 0.7, slopeBelow: 1, slopeAbove: 0.4, clampTime: 0.008, relaxTime: 0.2);
		sig = tanh(sig).softclip;
		sig;
	}
});

Library.put(\fx, \limiter, {
	{arg in;
		Limiter.ar(in, -6.dbamp);
	}
});

Library.put(\fx, \bufglitch, {arg bufdur=16;

	{arg in;

		var buf = LocalBuf(bufdur * 44100, 2).clear;
		var rec = {
			var trig = \rectrig.tr;
			var offset = \offset.kr(0);
			var recLevel = \reclevel.kr(1);
			var preLevel = \prelevel.kr(0);
			var run = \run.kr(0);
			var loop = \recloop.kr(0);
			RecordBuf.ar(in, buf, offset:offset, recLevel:recLevel, preLevel:preLevel, run:run, loop:loop, trigger:trig);
		}.();

		var rateL = \rateL.kr(3);
		var rateR = \rateR.kr(4);
		var interval = \interval.kr(4);
		var trig = Impulse.kr([rateL,rateR]);
		var gate = TChoose.kr(PulseDivider.kr(trig, interval), [1, 0]);
		var rev = \rev.kr(0.4);
		var loop = \loop.kr(1);
		var frames = BufFrames.kr(buf);
		var sus = TChoose.kr(trig, [0.5, 2, 1]);
		var start = Latch.kr(WhiteNoise.kr().range(0, 1), trig) * frames;
		var rate = TWChoose.kr(trig,
			[12, 7, 5, 24].midiratio,
			[4, 3, 2, 1].normalizeSum) * TWChoose.kr(PulseDivider.kr(trig, 4), [1, -1], [1-rev, rev]);
		var env = Env([0, 1, 1, 0], [0.01, sus-0.01-0.01, 0.01], curve:\lin).kr(gate:trig);
		var sig = PlayBufCF.ar(2, buf, rate, trig, start, loop);
		sig = sig * env * \amp.kr(-3.dbamp) * gate;
		Splay.ar(sig.flatten);
	};
});

Library.put(\fx, \delay, {arg maxdelay=1;
	var beatudur = TempoClock.default.beatDur;
	"maxdelay %".format(maxdelay).debug(\fx);
	{arg in;
		in = LPF.ar(HPF.ar(in, \delhi.kr(20)), \dello.kr(20000));
		FbC({arg fb; fb.reverse * [\fbL.kr(0.2), \fbR.kr(0.3)] + in;},
			maxdelay,
			\beatdur.kr(beatudur) * [\delL.kr(3/4), \delR.kr(5/8)]
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
		var res = \res.kr(0.1).linexp(0, 1, 1, 0.001);
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
		var res = \res.kr(0.1).linexp(0, 1, 1, 0.001);
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
		var res = \res.kr(0.1).linexp(0, 1, 1, 0.001);
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
		var res = \res.kr(0.1).linexp(0, 1, 1, 0.001);
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
		var sig = Squiz.ar(in, [\prL.kr(1.5), \prR.kr(2)], \zcp.kr(1));
		LeakDC.ar(sig);
	}
});

Library.put(\fx, \pitchshift, {arg windowSize=0.2;
	"pitchshift windowsize: %".format(windowSize).debug(\pitchshift);
	{arg in;
		PitchShift.ar(in, windowSize, [\psRatioL.kr(1), \psRatioR.kr(2)], \pitchDispersion.kr(0.01), \timeDispersion.kr(0.01));
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
		var sig = WaveLoss.ar(in, [\dropL.kr(20), \dropR.kr(20)], \outof.kr(40), \mode.kr(1));
		LeakDC.ar(sig);
	}
});

)