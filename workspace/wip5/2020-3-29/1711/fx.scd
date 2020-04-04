(
/*
https://www.listarc.bham.ac.uk/lists/sc-users-2009/msg54361.html
Waveshaper

References : Posted by Partice Tarrabia and Bram de Jong

Notes :
amount should be in [-1..1[ Plot it and stand back in astonishment! ;)

Code :
x = input in [-1..1]
y = output
k = 2*amount/(1-amount);

f(x) = (1+k)*x/(1+k*abs(x))
http://www.musicdsp.org/archive.php?classid=4#203

(
{
	var x = SinOsc.ar(220, 0, 0.8);
	var amount = MouseX.kr(-1, 1);
	var k = 2 * amount / (1 - amount);
	(1 + k) * x / (1 + (k * x.abs));
}.scope

)
*/


// steal from here - https://github.com/musikinformatik/SuperDirt/blob/develop/synths/core-synths.scd

Library.put(\fx, \sat2, {
	{arg in;
		var amount = 0.99;
		var amCoef= 2*amount/(1-amount);
		in = HPF.ar(in, 400)*5;
		MidEQ.ar(LPF.ar((1+amCoef)*in/(1+(amCoef*in.abs)), [3800, 3900]) *0.5, 120, 0.7, 8);
	};
});

Library.put(\fx, \crush, {arg crush=4;
	crush.debug(\crush);
	{arg in;
		var sig = in.round(0.5 ** \crush.kr(crush));
		sig;
	}
});

Library.put(\fx, \shaper, {
	{arg in;
		var sig = in;
		sig = Shaper.ar(\buf.kr(0), sig);
		sig = LeakDC.ar(sig);
		sig;
	}
});

Library.put(\fx, \saturate, {
	{arg in;
		var sig = in;
		var gain = \gain.kr(1);
		sig = (sig * gain).tanh * (gain.reciprocal.sqrt);
		sig = LeakDC.ar(sig);
		sig;
	}
});

Library.put(\fx, \softclip, {
	{arg in;
		var sig = in;
		sig = SoftClipAmp8.ar(sig, \gain.kr(1));
		sig = LeakDC.ar(sig);
		sig;
	}
});

Library.put(\fx, \reversedelay, {
	/*
	specs: [
	\delay -> [0, 5, \lin, 0, 1],
	\feedback -> [0, 1, \lin, 0, 0.5],
	\crossfade -> [0, 100, \lin, 0, 20],
	]
	*/
	{arg in;
		var sig = in;
		sig = LADSPA.ar(1, 1605,
			sig,
			\delay.kr(1).lag(0.1),
			-70, // dry
			0, // wet
			\feedback.kr(0.5).lag(0.1),
			\crossfade.kr(20)
		);
		sig;
	}
});

Library.put(\fx, \compressor, {
	{arg in;
		var sig = in;
		sig = CompanderD.ar(in: sig, thresh: 0.7, slopeBelow: 1, slopeAbove: 0.4, clampTime: 0.008, relaxTime: 0.2);
		sig = tanh(sig).softclip;
		sig;
	}
});

Library.put(\fx, \softkneecomp, {
	{arg in;
		var sig = in;
		sig = SoftKneeCompressor.ar(sig[0], sig[1],
			\thresh.kr(-10),
			\ratio.kr(1),
			\knee.kr(6),
			\attack.kr(0),
			\release.kr(0.05),
			\makeUp.kr(0),
			\rms.kr(0));
		sig;
	}
});

Library.put(\fx, \limiter, {
	{arg in;
		var sig = in;
		sig = Limiter.ar(sig, -6.dbamp);
		sig;
	}
});

Library.put(\fx, \bufglitch, {arg bufdur=16;

	{arg in;
		var sig = in;
		var buf = LocalBuf(bufdur * 44100, 2).clear;
		var rec = {
			var trig = \rectrig.tr;
			var offset = \offset.kr(0);
			var recLevel = \reclevel.kr(1);
			var preLevel = \prelevel.kr(0);
			var run = \run.kr(0);
			var loop = \recloop.kr(0);
			RecordBuf.ar(sig, buf, offset:offset, recLevel:recLevel, preLevel:preLevel, run:run, loop:loop, trigger:trig);
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
		sig = PlayBufCF.ar(2, buf, rate, trig, start, loop);
		sig = sig * env * \amp.kr(-3.dbamp) * gate;
		sig = Splay.ar(sig.flatten);
		sig;
	};
});

Library.put(\fx, \delay, {arg maxdelay=1;

	var beatudur = TempoClock.default.beatDur;
	"maxdelay %".format(maxdelay).debug(\fx);

	{arg in;
		var sig = in;
		sig = LPF.ar(HPF.ar(sig, \delhi.kr(20)), \dello.kr(20000));
		sig = FbC({arg fb; fb.reverse * [\fbL.kr(0.2), \fbR.kr(0.3)] + sig;},
			maxdelay,
			\beatdur.kr(beatudur) * [\delL.kr(3/4), \delR.kr(5/8)]
		);
		sig
	};
});

Library.put(\fx, \reverb, {
	{arg in;
		var sig = in;
		sig = LPF.ar(HPF.ar(sig, \revhi.kr(20)), \revlo.kr(20000));
		sig = JPverb.ar(sig, \t60.kr(1), 0,
			\size.kr(1),
			\earlyDiff.kr(0.707),
			\modDepth.kr(0.1),
			\modFreq.kr(2.0)
		);
		sig;
	}
});

Library.put(\fx, \nhhall, {
	{arg in;
		var sig = in;
		sig = NHHall.ar(sig,
			\rt60.kr(1).lag(0.1),
			\stereo.kr(0.5),
			\lowFreq.kr(200),
			\lowRatio.kr(0.5),
			\hiFreq.kr(4000),
			\hiRatio.kr(0.5),
			\earlyDiffusion.kr(0.5),
			\lateDiffusion.kr(0.5),
			\modRate.kr(0.2),
			\modDepth.kr(0.3)
		);
		sig;
	}
});

Library.put(\fx, \reverb3, {
	{arg in;
		var sig = in;
		sig = AdCVerb.ar(sig,
			revTime:\revTime.kr(3),
			hfDamping:\hfDamping.kr(0.1),
			nOuts:2,
			predelay:\predelay.kr(0.02),
			numCombs:8,
			numAllpasses:4,
			inFilter:\inFilter.kr(0.6),
			combScale:\combScale.kr(3).lag(0.1),
			apScale:\apScale.kr(3).lag(0.1)
		);
		sig;
	}
});

Library.put(\fx, \disintigrator, {
	{arg in;
		var sig = in;
		sig = Disintegrator.ar(sig,
			probability:\prob.kr(0.5),
			multiplier:\mult.kr(0)
		);
		sig = LeakDC.ar(sig);
		sig;
	}
});

Library.put(\fx, \decimator, {
	{arg in;
		var sig = in;
		sig = Decimator.ar(sig,
			rate: 44100/\rate.kr(1).clip(1,10),
			bits: \bits.kr(24)
		);
		sig = LeakDC.ar(sig);
		sig;
	}
});

Library.put(\fx, \bandpass, {
	{arg in;
		var sig = in * \pregain.kr(1);
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
		var res = \res.kr(0.1).linlin(0, 1, 1, 0.001);
		var ffreq = Env(
			[0, 1, suslevel, suslevel, 0],
			[atk, dec, sus, rel],
			[curve1,curve2,curve3]
		).kr(gate:\trig.tr).linexp(0, 1, cutoff, cutoff * vel);
		sig = BBandPass.ar(sig, ffreq.clip(20, 20000), res);
		sig * \postgain.kr(1);
	}
});

Library.put(\fx, \dfm1, {
	{arg in;
		var sig = in * \pregain.kr(1);
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
			[0, 1, suslevel, suslevel, 0],
			[atk, dec, sus, rel],
			[curve1,curve2,curve3]
		).kr(gate:\trig.tr).linexp(0, 1, cutoff, cutoff * vel);
		sig = DFM1.ar(sig, ffreq.clip(20, 20000), res);
		sig * \postgain.kr(1);
	}
});

Library.put(\fx, \lopass4, {
	{arg in;
		var sig = in * \pregain.kr(1);
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
		var res = \res.kr(0.1).linlin(0, 1, 1, 0.001);
		var ffreq = Env(
			[0, 1, suslevel, suslevel, 0],
			[atk, dec, sus, rel],
			[curve1,curve2,curve3]
		).kr(gate:\trig.tr).linexp(0, 1, cutoff, cutoff * vel);
		sig = BLowPass4.ar(sig, ffreq.clip(20, 20000), res);
		sig * \postgain.kr(1);
	}
});

Library.put(\fx, \hipass4, {
	{arg in;
		var sig = in * \pregain.kr(1);
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
		var res = \res.kr(0.1).linlin(0, 1, 1, 0.001);
		var ffreq = Env(
			[0, 1, suslevel, suslevel, 0],
			[atk, dec, sus, rel],
			[curve1,curve2,curve3]
		).kr(gate:\trig.tr).linexp(0, 1, cutoff, cutoff * vel);
		sig = BHiPass4.ar(sig, ffreq.clip(20, 20000), res);
		sig * \postgain.kr(1);
	}
});

Library.put(\fx, \rlpf_ad, {
	{arg in;
		var sig = in * \pregain.kr(1);
		var res = \res.kr(0.1).linlin(0, 1, 1, 0.001);
		var cutoff = \cutoff.kr(1000);
		var vel = \fvel.kr(2);
		var peak = cutoff * vel;
        var ffreq = Decay2.ar(K2A.ar(\trig.tr), \fatk.kr(0.01), \fdec.kr(1)).lincurve(0, 1, cutoff, peak, \fcurve.kr(-4));
		sig = RLPF.ar(sig, ffreq.clip(20, 20000), res);
		sig * \postgain.kr(1);
	}
});

Library.put(\fx, \rlpf_adsr, {
	{arg in;
		var sig = in * \pregain.kr(1);
		var suslevel = \fsuslevel.kr(1);
		var atk = \fatk.kr(0.01);
		var dec = \fdec.kr(0);
		var sus = \fsus.kr(0);
		var rel = \frel.kr(1);
		var curve1 = \fcurve1.kr(-4);
		var curve2 = \fcurve2.kr(-4);
		var curve3 = \fcurve3.kr(-4);
		var cutoff = \cutoff.kr(1000);
		var vel = \fvel.kr(2);
		var res = \res.kr(0.1).linlin(0, 1, 1, 0.001);
		var ffreq = Env(
			[0, 1, suslevel, suslevel, 0],
			[atk, dec, sus, rel],
			[curve1,curve2,curve3]
		).kr(gate:\trig.tr).linexp(0, 1, cutoff, cutoff * vel);
		sig = RLPF.ar(sig, ffreq.clip(20, 20000), res);
		sig * \postgain.kr(1);
	}
});

Library.put(\fx, \squiz, {
	{arg in;
		var sig = in * \pregain.kr(1);
		sig = Squiz.ar(sig, [\prL.kr(1.5), \prR.kr(2)], \zcp.kr(1));
		sig = LeakDC.ar(sig);
		sig * \postgain.kr(1);
	}
});

Library.put(\fx, \pitchshift, {arg windowSize=0.2;
	"pitchshift windowsize: %".format(windowSize).debug(\pitchshift);
	{arg in;
		var sig = in;
		sig = PitchShift.ar(sig, windowSize, [\psRatioL.kr(1), \psRatioR.kr(2)], \pitchDispersion.kr(0.01), \timeDispersion.kr(0.01));
		sig;
	}
});

Library.put(\fx, \greyhole, {
	{arg in;
		var sig = in * \pregain.kr(1);
		sig = Greyhole.ar(sig,
			\ghdelayTime.kr(2.0),
			\ghdamp.kr(0),
			\ghsize.kr(1.0),
			\ghdiff.kr(0.707),
			\ghfeedback.kr(0.9),
			\ghmodDepth.kr(0.1),
			\ghmodFreq.kr(2.0)
		);
		sig * \postgain.kr(1);
	}
});

Library.put(\fx, \waveloss, {
	{arg in;
		var sig = in * \pregain.kr(1);
		sig = WaveLoss.ar(sig, [\dropL.kr(20), \dropR.kr(20)], \outof.kr(40), \mode.kr(1));
		sig = LeakDC.ar(sig);
		sig * \postgain.kr(1);
	}
});

)