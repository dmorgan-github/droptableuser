(
Library.put(\funcs, \wavegen, {arg buf, timbre=0, seed=nil, len=1024;
	// this is derived from Eli Fieldsteel's tutorial on wavetables
	// timbre is = 0 through 9
	// len should be numFrames/2
	var env;
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
});

Library.put(\funcs, \parse, {arg str;

	/*
	[
		\corliwud -> "|    k           |/4",
		\uihzrca  -> "|  j  n          |/2",
		\sioe     -> "|m      b b      |/4"
	],
	*/

	var doparse, result, amps, rates, weights, durs, stretch, i;

	doparse = {arg str, pos=0, context=\p, result = [nil,nil,nil,nil,nil,nil];

		var current = str[pos];
		var pattern = result[0];
		var amps = result[1];
		var rates = result[2];
		var weights = result[3];
		var durs = result[4];
		var stretch = result[5];

		if (pos < str.size) {
			switch(current.ascii,
				9, {/*tab*/},
				10, {/*new line*/},
				37, {/*percent*/ weights = List.new; context = \w},
				42, {/*star*/ amps = List.new; context = \a},
				43, {/*plus*/ stretch = List.new; context = \s},
				47, {/*forward slash*/ durs = List.new; context = \d},
				94, {/*caret*/ rates = List.new; context = \r},
				124, {/*pipe*/ if (pattern.isNil) {pattern = List.new; context = \p}},
				{
					switch(context,
						\p, {
							if (current.isAlpha) {
								pattern.add(Library.at(\bufs, current.asSymbol))
							}{
								if (current == Char.space) {
									pattern.add(Rest());
								} {
									"invalid token %".format(current).postln
								}
							};
						},
						\a, {
							var val = current.asString.hexToInt;
							amps.add(val/35);
						},
						\r, {
							var val = current.asString.hexToInt;
							rates.add(val.linlin(0, 35, 0.1, 4));
						},
						\w, {
							var val = current.asString.asInt;
							weights.add(val);
						},
						\d, {
							var val = current.asString.asInt;
							if (val > 0) {
								durs.add(val);
							} {
								"invalid dur: %".format(val).postln;
							}
						},
						\s, {
							var val = current.asString.asInt;
							if (val > 0) {
								stretch.add(val);
							} {
								"invalid stretch: %".format(val).postln;
							}
						}
					);
				}
			);
			result = doparse.(str, pos+1, context, [pattern, amps, rates, weights, durs, stretch]);
		};
		result;
	};
	result = doparse.(str);

	// map the amps to the pattern
	i = 0;
	amps = result[0]
	.collect({arg val; if (val.isRest) {\}{var a = if (result[1].isNil.not) {result[1].wrapAt(i)}; i = i + 1; a;} })
	.collect({arg val; if (val.isNil){1}{val}});

	// map the rates to the pattern
	i = 0;
	rates = result[0]
	.collect({arg val; if (val.isRest) {\}{var r = if(result[2].isNil.not){result[2].wrapAt(i)}; i = i + 1; r;} })
	.collect({arg val; if (val.isNil){1}{val}});

	// map the weights to the pattern
	i = 0;
	weights = result[0]
	.collect({arg val; if (val.isRest) {\}{var r = if(result[3].isNil.not){result[3].wrapAt(i)/9}; i = i + 1; r;} })
	.collect({arg val; if (val.isNil){1}{val}});

	durs = result[4];
	if (durs.isNil or: (durs.size == 0)) {
		durs = [1]
	};

	stretch = result[5];
	if (stretch.isNil or: (stretch.size == 0)) {
		stretch = [1];
	};

	[result[0], amps, rates, weights, durs, stretch];
});

Library.put(\funcs, \loadbufs, {arg bufs, dir;

	if (dir.isNil){
		dir = Document.current.dir.postln;
	};

	bufs.do({arg kv;
		var key = kv.key;
		var val = kv.value;
		var path = dir ++ "/samples/" ++ val ++ ".wav";
		var buf = Library.at(\bufs, key);
		if (buf.isNil) {
			"loading buf % from %".format(key, path).postln;
			Library.put(\bufs, key, Buffer.read(Server.default, path));
		} {
			if (buf.path != path) {
				"loading buf % from %".format(key, path).postln;
				Library.put(\bufs, key, Buffer.read(Server.default, path));
			} {
				"buf % from % already exists".format(key, path).postln;
			}
		}
	});
});
)