(
~gverb = {arg chans = 2, roomsize = 20, revtime = 3, damp = 0.5,
	bw = 0.5, spread = 15, dry = 1, earlyreflevel = 0.7, taillevel = 0.5, lr = false;

	{
		var in = \in.ar(0.dup(chans));
		GVerb.ar(Mix.ar(in), roomsize,
			\revtime.kr(revtime),
			\damping.kr(damp),
			\inputbw.kr(bw),
			\spread.kr(spread),
			\drylevel.kr(dry),
			\earlyreflevel.kr(earlyreflevel),
			\taillevel.kr(taillevel)
		);
	};
};
)