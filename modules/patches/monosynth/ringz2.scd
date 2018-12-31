(
SynthDef(\ringz, {

	var freq = \freq.kr(523);
	var trig = Trig.ar(\trig.tr(1), 0.0001);

	// not sure why this seems to work
	var ex = Latch.ar(PinkNoise.ar(0.2), trig);
	var sig = Formlet.ar(ex, freq: freq, attacktime: 0.001, decaytime: 1);

	sig = Pan2.ar(sig, Rand(-1.0, 1.0)) * \amp.kr(-20.dbamp);
	DetectSilence.ar(sig, doneAction:Done.freeSelf);
	Out.ar(\out.kr(0), sig);

}).add;


SynthDef(\ringz2, {

	var freq = \freq.kr(523);
	var trig = Trig.ar(\trig.tr(1), 0.0001);

	// not sure why this seems to work
	var ex = Latch.ar(PinkNoise.ar(0.2), trig);
	var sig = Formlet.ar(ex, freq: freq * SinOsc.kr(15).range(9, 12).midiratio, attacktime: 0.001, decaytime: 1);

	sig = Pan2.ar(sig, Rand(-1.0, 1.0)) * \amp.kr(-20.dbamp);
	DetectSilence.ar(sig, doneAction:Done.freeSelf);
	Out.ar(\out.kr(0), sig);

}).add;
)

(
var ring2 = [
	'C4' -> [32, 24, 5],
	'D#4' -> [25, 21, 13],
	'G4' -> [23, 43, 53]
];

var ptrn = ring2.collect({arg assoc;

	var note = assoc.key.namecps;
	var divs = assoc.value;
	var pbinds = divs.collect({arg div;
		Pbind(\instrument, \ringz, \trig, Pwhite(0.5, 1), \dur, div * 0.25, \freq, note)
	});
	pbinds;
});

Pdef(\ringz1, Ppar(ptrn.flatten, inf))
)


(
var rings = [
	'C3' -> [28, 11, 34],
	'G3' -> [19, 51, 59],
	'D3' -> [24, 16, 36]
];

var ptrn = rings.collect({arg assoc;

	var note = assoc.key.namecps;
	var divs = assoc.value;
	var pbinds = divs.collect({arg div;
		Pbind(\instrument, \ringz, \trig, Pwhite(0.5, 1, inf), \dur, div * 0.25, \freq, note)
	});
	pbinds;
});

Pdef(\ringz2, Ppar(ptrn.flatten, inf))
)

(
var rings = [
	'C3' -> [34, 32, 51],
	'C4' -> [27, 34, 26],
	'C5' -> [25, 56, 61]
];

var ptrn = rings.collect({arg assoc;

	var note = assoc.key.namecps;
	var divs = assoc.value;
	var pbinds = divs.collect({arg div;
		Pbind(\instrument, \ringz2, \trig, Pwhite(0.5, 1, inf), \dur, div * 0.25, \freq, note)
	});
	pbinds;
});

Pdef(\ringz3, Ppar(ptrn.flatten, inf))
)


Pdef(\ringz1).play;

~ringz1 = Pdef(\ringz1);
~ringz1.play;

~ringz2 = Pdef(\ringz2);
~ringz2.play;

~ringz3 = Pdef(\ringz3);
~ringz3.play;



(
~bobo3 = {

	var sig;

	var trig1 = \trig1.ar;
	var trig2 = \trig2.ar;
	var trig3 = \trig3.ar;

	var sig1 = Trig1.ar(trig1, 0.001);
	var sig2 = Trig1.ar(trig2, 0.001);
	var sig3 = Trig1.ar(trig3, 0.001);

	sig1 = Ringz.ar(sig1, 'C4'.namecps, 1);
	sig2 = Ringz.ar(sig2, 'D4'.namecps, 1);
	sig3 = Ringz.ar(sig3, 'G4'.namecps, 1);

	sig = Splay.ar([sig1, sig2, sig3]) * -25.dbamp;

	sig = JPverb.ar(sig, 2, 0, 5) * 0.4 + sig;

	sig;
};

~bobo3[2] = \set -> Pbind(
	\trig1, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (32 * 0.25) - 0.1], inf)
);

~bobo3[4] = \set -> Pbind(
	\trig1, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (24 * 0.25) - 0.1], inf)
);

~bobo3[6] = \set -> Pbind(
	\trig1, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (5 * 0.25) - 0.1], inf)
);

~bobo3[8] = \set -> Pbind(
	\trig2, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (25 * 0.25) - 0.1], inf)
);

~bobo3[10] = \set -> Pbind(
	\trig2, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (21 * 0.25) - 0.1], inf)
);

~bobo3[12] = \set -> Pbind(
	\trig2, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (13 * 0.25) - 0.1], inf)
);

~bobo3[14] = \set -> Pbind(
	\trig3, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (23 * 0.25) - 0.1], inf)
);

~bobo3[16] = \set -> Pbind(
	\trig3, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (43 * 0.25) - 0.1], inf)
);

~bobo3[18] = \set -> Pbind(
	\trig3, Pseq([1, 0], inf),
	\dur, Pseq([0.1, (53 * 0.25) - 0.1], inf)
);

)

~bobo3.play;
~bobo3.stop;