(
~squiz = {arg chans = 1, pitchratio = 2, zcperchunk = 1;

	{
		var in = \in.ar(0.dup(chans));
		var fx = Squiz.ar(in,
			[\pitchratioL.kr(pitchratio),\pitchratioR.kr(pitchratio)],
			[\zcperchunkL.kr(zcperchunk),\zcperchunkR.kr(zcperchunk)]
		);
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	}
};

~waveloss = {arg chans = 1, drop = 20, outof = 40;

	{
		var in = \in.ar(0.dup(chans));
		var fx = WaveLoss.ar(in,
			[\dropL.kr(drop),\dropR.kr(drop)],
			[\outofL.kr(outof),\outofR.kr(outof)]
		);
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	}
};

~disintegrator = {arg chans = 1, prob = 0.5, mult = 0;

	{
		var in = \in.ar(0.dup(chans));
		var fx = Disintegrator.ar(in,
			[\probL.kr(prob),\probR.kr(prob)],
			[\multL.kr(mult),\multR.kr(mult)]
		);
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	}
};

~decimator = {arg chans = 1, rate = 44100, bits = 24;

	{
		var in = \in.ar(0.dup(chans));
		var fx = Decimator.ar(in,
			[\rateL.kr(rate),\rateR.kr(rate)],
			[\bitsL.kr(bits),\bitsR.kr(bits)]
		);
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	}
};

/*
# 1408 Barry's Satan Maximiser
> k: Decay time (samples) (2 to 30)
> k: Knee point (dB) (-90 to 0)
> a: Input
< a: Output
*/
~barrys = {arg chans = 1, decay = 15, kneepoint = -10;

	{
		var in = \in.ar(0.dup(chans));
		var fx = LADSPA.ar(1, 1408,
			[\decayL.kr(decay), \decayR.kr(decay)],
			[\kneepointL.kr(kneepoint), \kneepointR.kr(kneepoint)],
			in
		);
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	}
};

)