
(
~bobo = {

	var sig;

	var trig1 = \trig1.kr;
	var trig2 = \trig2.kr;
	var trig3 = \trig3.kr;

	var noises = [PinkNoise.ar(0.5), BrownNoise.ar(0.5), WhiteNoise.ar(0.5)];

	// not sure why this seems to work
	var sig1 = Latch.ar(
		SelectXFocus.ar(SinOsc.kr(0.1).range(0,2).round, noises, LFNoise2.kr(0.1).range(0,1)),
		trig1
	);
	var sig2 = Latch.ar(
		SelectXFocus.ar(SinOsc.kr(0.01).range(0,2).round, noises, LFNoise2.kr(0.2).range(0,1)),
		trig2
	);
	var sig3 = Latch.ar(
		SelectXFocus.ar(SinOsc.kr(0.02).range(0,2).round, noises, LFNoise2.kr(0.03).range(0,1)),
		trig3
	);

	sig1 = Ringz.ar(sig1, 'C4'.namecps, 1);
	sig2 = Ringz.ar(sig2, 'D4'.namecps, 1);
	sig3 = Ringz.ar(sig3, 'G4'.namecps, 1);

	sig = Splay.ar([sig1, sig2, sig3]) * -25.dbamp;

	sig = JPverb.ar(sig, 2, 0, 5) * 0.4 + sig;

	sig;
};

~bobo[2] = \set -> Pbind(
	\trig1, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (32 * 0.25) - 0.1], inf)
);

~bobo[4] = \set -> Pbind(
	\trig1, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (24 * 0.25) - 0.1], inf)
);

~bobo[6] = \set -> Pbind(
	\trig1, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (5 * 0.25) - 0.1], inf)
);

~bobo[8] = \set -> Pbind(
	\trig2, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (25 * 0.25) - 0.1], inf)
);

~bobo[10] = \set -> Pbind(
	\trig2, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (21 * 0.25) - 0.1], inf)
);

~bobo[12] = \set -> Pbind(
	\trig2, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (13 * 0.25) - 0.1], inf)
);

~bobo[14] = \set -> Pbind(
	\trig3, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (23 * 0.25) - 0.1], inf)
);

~bobo[16] = \set -> Pbind(
	\trig3, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (43 * 0.25) - 0.1], inf)
);

~bobo[18] = \set -> Pbind(
	\trig3, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (53 * 0.25) - 0.1], inf)
);

)

TempoClock.default.tempo_(94/60)



(
~bobo2 = {


	var sig;

	var trig1 = \trig1.kr;
	var trig2 = \trig2.kr;
	var trig3 = \trig3.kr;

	var sig1 = Latch.ar(PinkNoise.ar(), trig1);
	var sig2 = Latch.ar(PinkNoise.ar(), trig2);
	var sig3 = Latch.ar(PinkNoise.ar(), trig3);

	sig1 = Ringz.ar(sig1, 'C3'.namecps, 1);
	sig2 = Ringz.ar(sig2, 'G3'.namecps, 1);
	sig3 = Ringz.ar(sig3, 'D3'.namecps, 1);

	//sig1 = sig1 * trig1;
	//sig2 = sig2 * trig2;
	//sig3 = sig3 * trig3;

	sig = Splay.ar([sig1, sig2, sig3]) * -25.dbamp;

	//sig = sig.asArray.sum * -12.dbamp;
	//sig = Splay.ar(sig) * 0.dbamp;

	//sig = MidEQ.ar(sig, 880, -20.dbamp);

	//sig = FbC({arg fb; fb * 0.4 + sig}, 0.05) * 0.5 + sig;

	sig = JPverb.ar(sig, 2, 0, 5) * 0.4 + sig;

	sig;
};

~bobo2[2] = \set -> Pbind(
	\trig1, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (28 * 0.25) - 0.1], inf)
);

~bobo2[4] = \set -> Pbind(
	\trig1, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (11 * 0.25) - 0.1], inf)
);

~bobo2[6] = \set -> Pbind(
	\trig1, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (34 * 0.25) - 0.1], inf)
);

~bobo2[8] = \set -> Pbind(
	\trig2, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (19 * 0.25) - 0.1], inf)
);

~bobo2[10] = \set -> Pbind(
	\trig2, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (51 * 0.25) - 0.1], inf)
);

~bobo2[12] = \set -> Pbind(
	\trig2, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (59 * 0.25) - 0.1], inf)
);

~bobo2[14] = \set -> Pbind(
	\trig3, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (24 * 0.25) - 0.1], inf)
);

~bobo2[16] = \set -> Pbind(
	\trig3, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (16 * 0.25) - 0.1], inf)
);

~bobo2[18] = \set -> Pbind(
	\trig3, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (36 * 0.25) - 0.1], inf)
);

)

~bobo.play;
~bobo.stop;

~bobo2.play;
~bobo2.stop



(94/60) / 16