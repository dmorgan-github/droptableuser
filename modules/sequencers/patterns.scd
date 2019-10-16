/////////////////////////////////////////
// step sequencer with grouped parameters
(
Pdef(\step, {
	Pbind(
		\type, \rest,
		\steps, Pn([
			[\a1, \a2, \a3],
			[\b1, \b2, \b3],
			[\c1, \c2, \c3],
			\!3
		], inf),
		\len, Pfunc({arg evt; evt[\steps].size}),
		\step, Pseries(0, 1, inf).mod(Pkey(\len)),
		[\x, \y, \z], Pindex(Pkey(\steps), Pkey(\step), inf),
		\dur, 0.5
	)
})
)

Pdef(\step).play;
Pdef(\step).stop;

/////////////////////////////////////////
// xy sequencer
(
Pdef(\xy, {
	Pbind(
		\type, \rest,
		\xy, Ptuple([
			[1, 0, 0, 8],
			[0, 3, 6, 0],
			[0, 4, 5, 0],
			[2, 0, 0, 7]
		], inf).collect(`_),
		\x, Pseries(0, 1).stutter(8),
		\y, Pseries(0, 1).stutter(2),
		\foo, Pfunc({arg evt;
			var x = evt[\x];
			var y = evt[\y];
			var xy = evt[\xy];
			var val = xy.next.wrapAt(y).next.wrapAt(x).next;
			val;
		}).trace
	)
})
)


Pdef(\xy).play;
Pdef(\xy).stop;
