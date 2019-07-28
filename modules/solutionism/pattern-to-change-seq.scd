Pdefn(\test123, Prand([0, 1, 2, 3], inf));
Pdefn(\test123, Pseries().mod(4));

(
Pdefn(\test123, Pseries().mod(4));

Pdefn(\notes, 40 + [0, 3, 5, 7]);

Pdef(\seq, Pbind(
	\scale, Scale.chromatic,
	\dur, 0.25, \legato, 3,
	\foo, Pdefn(\test123),
	\midinote, Pdefn(\notes).composeBinaryOp(\wrapAt, Pkey(\foo)),
	\amp, 0.5
)).play;

fork {
	loop {
		Pdefn(\notes, 40 + [0, 3, 5, 9]);
		8.rand.wait;
		Pdefn(\notes, 40 + [0, 3, 5, 8]);
		8.rand.wait;
		Pdefn(\notes, 40 + [0, 3, 5, 7]);
		8.rand.wait;
	}
}
)