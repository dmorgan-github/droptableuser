(
Library.put(\funcs, \wavegen, {arg buf, timbre=0, seed=nil, len=1024;
	// timbre is = 0 through 9
	// len should be numFrames/2
	var env;
	{
		var segs = timbre.linexp(0,9,4,40).round;
		if (seed.isNil) {
			thisThread.randSeed_(1000000.rand.debug("rand seed"));
		}{
			thisThread.randSeed_(seed);
		};
		env = Env(
			// levels
			[0] ++ ({1.0.rand}.dup(segs-1) * [1,-1]).scramble ++ [0],
			// times
			{ exprand(1, timbre.linexp(0,9,1,50)) }.dup(segs),
			// curves
			{[\sine, 0, exprand(1,20) * [1,-1].choose].wchoose([9-timbre,3,timbre].normalizeSum)}.dup(segs);
		);
		buf.setn(0, env.asSignal(len).asWavetable);
		[\levels, env.levels, \times, env.times, \curves, env.curves].debug(\wavegen);
	}.defer(0);
});
)