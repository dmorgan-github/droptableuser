(
~squiz = {arg chans = 1, pitchratio = 2, zcperchunk = 1, lr = false;

	{
		var in = \in.ar(0.dup(chans));
		var fx = if (lr) {
			Squiz.ar(in,
				[\pitchratioL.kr(pitchratio),\pitchratioR.kr(pitchratio)],
				[\zcperchunkL.kr(zcperchunk),\zcperchunkR.kr(zcperchunk)]
			);
		} {
			Squiz.ar(in,
				\pitchratio.kr(pitchratio),
				\zcperchunk.kr(zcperchunk)
			);
		};
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	}
};

~waveloss = {arg chans = 1, drop = 20, outof = 40, lr = false;

	{
		var in = \in.ar(0.dup(chans));
		var fx = if () {
			WaveLoss.ar(in,
				[\dropL.kr(drop),\dropR.kr(drop)],
				[\outofL.kr(outof),\outofR.kr(outof)]
			);
		} {
			WaveLoss.ar(in,
				\drop.kr(drop),
				\outof.kr(outof)
			);
		};
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	}
};

~disintegrator = {arg chans = 1, prob = 0.5, mult = 0, lf = false;

	{
		var in = \in.ar(0.dup(chans));
		var fx = if () {
			Disintegrator.ar(in,
				[\probL.kr(prob),\probR.kr(prob)],
				[\multL.kr(mult),\multR.kr(mult)]
			);
		} {
			Disintegrator.ar(in,
				\prob.kr(prob),
				\mult.kr(mult)
			);
		};
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	}
};

~decimator = {arg chans = 1, rate = 44100, bits = 24, lr = false;

	{
		var in = \in.ar(0.dup(chans));
		var fx = if (lr) {
			Decimator.ar(in,
				[\rateL.kr(rate),\rateR.kr(rate)],
				[\bitsL.kr(bits),\bitsR.kr(bits)]
			);
		} {
			Decimator.ar(in,
				\rate.kr(rate),
				\bits.kr(bits)
			);
		};
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
~barrys = {arg chans = 1, decay = 15, kneepoint = -10, lr = false;

	{
		var in = \in.ar(0.dup(chans));
		var fx = if () {
			LADSPA.ar(1, 1408,
				[\decayL.kr(decay), \decayR.kr(decay)],
				[\kneepointL.kr(kneepoint), \kneepointR.kr(kneepoint)],
				in
			);
		} {
			LADSPA.ar(1, 1408,
				\decay.kr(decay),
				\kneepoint.kr(kneepoint),
				in
			);
		};
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	}
};

)