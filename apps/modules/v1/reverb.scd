(
~gverb = {arg roomsize = 20, chans = 2, revtime = 3, damp = 0.5,
	bw = 0.5, spread = 15, dry = 1, earlyreflevel = 0.7, taillevel = 0.5;
	{

		var in = \in.ar(0.dup(chans));
		var fx = GVerb.ar(Mix.ar(in), roomsize,
			[\revtimeL.kr(revtime),\revtimeR.kr(revtime)],
			[\dampingL.kr(damp),\dampingR.kr(damp)],
			[\inputbwL.kr(bw),\inputbwR.kr(bw)],
			[\spreadL.kr(spread),\spreadR.kr(spread)],
			[\drylevelL.kr(dry),\drylevelR.kr(dry)],
			[\earlyreflevelL.kr(earlyreflevel),\earlyreflevelR.kr(earlyreflevel)],
			[\taillevelL.kr(taillevel),\taillevelR.kr(taillevel)]
		);
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	};
};

~jpverb = {arg chans = 1, t60 = 1, damp = 0, size = 1, earlyDif = 0.707,
	modDepth = 0.1, modFreq = 2, low = 1, mid = 1, high = 1, lowcut = 500, highcut = 2000;

	{
		var in = \in.ar(0.dup(chans));
		var fx = JPverb.ar(in,
			[\t60L.kr(t60),\t60R.kr(t60)],
			[\dampL.kr(damp),\dampR.kr(damp)],
			[\sizeL.kr(size),\sizeR.kr(size)],
			[\earlyDiffL.kr(earlyDif),\earlyDiffR.kr(earlyDif)],
			[\modDepthL.kr(modDepth),\modDepthR.kr(modDepth)],
			[\modFreqL.kr(modFreq),\modFreqR.kr(modFreq)],
			[\lowL.kr(low),\lowR.kr(low)],
			[\midL.kr(mid),\midR.kr(mid)],
			[\highL.kr(high),\highR.kr(high)],
			[\lowcutL.kr(lowcut),\lowcutR.kr(lowcut)],
			[\highcutL.kr(highcut),\highcutR.kr(highcut)]
		);
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	}
};
)