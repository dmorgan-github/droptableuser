(
~barrys = {arg chans = 1, decay = 15, kneepoint = -10, lr = false;

	{
		var in = \in.ar(0.dup(chans));
		var fx = if (lr) {
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