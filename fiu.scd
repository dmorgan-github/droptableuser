s.makeGui;

S.fiu.synth = \subtractr;
S.fiu.play;
S.fiu.stop;
S.fiu.sgui;

(
S.fiu.set(
	\cutoff, nil,
	\fvel, 10,
	\res, 0.5,
	\tri, 0.01,
	\saw, 1,
	\pulse, 0,
	\sine, 0,
	\sineskew, 0,
	\detunehz, 0.7,
	\fel, 0.1,
	\suslevel, 0.8,
	\amp, 0.4,
	\rel, 0.2,
);
)

(
Pdef(\fiu_p1,

	Pbind(
		\dur, 0.125,
		\legato, 0.1,
		\vel, Pwhite(0.5, 1.0),
		\degree, Pstep(
			Ppatlace([
				Pseq([0, 4], inf),
				Pseq([-2, 2, -1, 1], inf)
			], inf),
			Pseq([2, 1, 0.5, 0.5], inf)
		),
		\octave, Pbjorklund(3, 8).linlin(0, 1, 5, 6),
		\cutoff, Ndef(\fiu_cutoff)
	) <> S.fiu
)
)

Pdef(\fiu_p1).play;
Pdef(\fiu_p1).stop;

Ndef(\fiu_cutoff, {\val.kr(100)});

(
Pdef(\fiu_play,
	Ppar([

		Pdef(\fiu_p1),
		Pbind(\timingOffset, 1.05, \mtranspose, 2, \rel, 0.4, \legato, 0.2) <> Pdef(\fiu_p1),
		Pbind(\dur, 0.5, \octave, 4, \legato, 0.5, \rel, 0.5, \amp, 0.15) <> Pdef(\fiu_p1),

		Pbind(
			\type, \set,
			\id, Pfunc({ Ndef(\fiu_cutoff).nodeID }),
			\args, #[\val],
			\val, Pseg([
				Pseq([80, 150, 80], inf)
			], [
				Pseq([4, 4, 0], inf)
			], -4, inf),
			\dur, 0.1
		)
	])
)
)

(
Pdef(\fiu_play,
	Ppar([

		Pdef(\fiu_p1),
		Pbind(\timingOffset, 1, \mtranspose, 2, \rel, 0.4, \legato, 0.2) <> Pdef(\fiu_p1),
		Pbind(\dur, 0.5, \octave, 4, \legato, 0.5, \rel, 0.5, \amp, 0.15) <> Pdef(\fiu_p1),

		Pbind(
			\type, \set,
			\id, Pfunc({ Ndef(\fiu_cutoff).nodeID }),
			\args, #[\val],
			\val, Pseg([
				Pseq([80, 150, 80], inf)
			], [
				Pseq([4, 4, 0], inf)
			], -4, inf),
			\dur, 0.1
		)
	])
)
)

Pdef(\fiu_play).fadeTime = 4;
Pdef(\fiu_play).play;
Pdef(\fiu_play).stop;