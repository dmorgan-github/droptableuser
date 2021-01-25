// presets

/////////////////////////////////////////////////////////////////////
// kicks
/////////////////////////////////////////////////////////////////////
Pdef(\kick, Pbind(\instrument, \kick, \octave, 2, \amp, -10.dbamp));


/////////////////////////////////////////////////////////////////////
// hi hats
/////////////////////////////////////////////////////////////////////
(
S.def(\hh_mono, {|freq, trig|

	var harm = 1.78;//MouseX.kr(-0.06, 2).poll;
	var k = (1..3);
	var ratio = {
		var val = k * (1.35 + ((k-1) * harm));
		val/val[0];
	}.();

	var myFreq = freq * ratio;
	var op3 = SinOscFB.ar(myFreq[2], \fb.kr(0));
	var op2 = SinOsc.ar(myFreq[1], (op3 * 50).mod(2pi));
	var op1 = SinOsc.ar(myFreq[0], (op2 * Env.perc(0, 0.1, 1, 14).ar(gate:trig) * 5).mod(2pi));
	var sig = HPF.ar(op1, \hpf.kr(9000)) * \gain.kr(2);
	sig;

}, \mono);

Pdef('hh_1', Pmono(\hh_mono,
	\octave, 5,
	\trig, 1,
	\amp, -20.dbamp,
	\legato, 0,
	\suslevel, 0,
	\dec, 0.05,
	\rel, 0)
);
)


/////////////////////////////////////////////////////////////////////
// buffer slicer
/////////////////////////////////////////////////////////////////////
(
~buf = ~buf ?? Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
~beats = nil;
~numslices = 8;
Pdef(\slicer,
	Pbind(
		\instrument, \smplr_1chan,
		\buf, Pfunc({~buf}),
		\cf, 0.05,
		\dir, 1, //[-1, 1].prand,
		\bufdur, Pfunc({|evt|
			var buf = evt[\buf];
			buf.duration;
		}),
		\numslices, Pfunc({|evt|
			if (~numslices.isNil) {8}{~numslices};
		}),
		\slicedur, Pkey(\numslices).reciprocal * Pkey(\bufdur),
		\slices, Pfunc({|evt|
			var numslices = evt[\numslices];
			(0..numslices-1)/numslices;
		}),
		\stretch, Pfunc({|evt|
			var len = ~beats;
			var bufdur = evt[\bufdur];
			var val = if (len.isNil) {1}{len/bufdur};
			val;
		}),
		\dur, Pkey(\slicedur),
		\speed, Pkey(\stretch).reciprocal,
		\sustain, Pkey(\dur) * Pkey(\stretch),
		\start, Plazy({|evt|
			var val = evt[\slices];
			Pseq(val, inf)
		}),
	)
)
)


/////////////////////////////////////////////////////////////////////
// sines
/////////////////////////////////////////////////////////////////////
Pdef(\sine_mono, Pmono(\sine_mono, \trig, 1));

/////////////////////////////////////////////////////////////////////
// pm2op
/////////////////////////////////////////////////////////////////////
Pdef(\pm2op_mono, Pmono(\pm2op_mono, \trig,1));

/////////////////////////////////////////////////////////////////////
// pm4
/////////////////////////////////////////////////////////////////////
(
Pdef(\pm4, Pbind(
	\instrument, \pm4,
	\detunehz, 1,
	\vdepth, 0.00,

	// rhythm
	\legato, 0.9,
	\dur, 0.25,
	\tempo, 1,

	// melody
	\scale, Scale.hexSus,
	\degree, Pshuf([-1, 0, 2, 4, 6, 7], inf),
	\octave, Pbjorklund(5, 8).linlin(0, 1, 3, Pseq([4, 5], inf)),

	// volume
	\amp, 0.3,
	\vel, Pseq([1, 0.5, 0.8, 0.7], inf),

	//////////////////////////////
	// operator 1
	\op1, 1,
	\op1ratio, 1,
	\op1atk, 0.01,
	\op1dec, 0.1,
	\op1suslevel, 1,
	\op1rel, 2,
	\op1curve, -4,
	// one-pole coefficient
	\op1coef, 0.2,
	\op1pan, Pwhite(-0.3, 0.3),

	// operator 2
	\op2, 0,
	\op2ratio, 2,
	\op2atk, 0.01,
	\op2dec, 0.1,
	\op2suslevel, 0.5,
	\op2rel, Pkey(\op1rel) * 0.5,
	\op2curve, 2,
	// one-pole coefficient
	\op2coef, 0.3,
	\op2pan, Pwhite(-0.3, 0.3),

	// operator 3
	\op3, 0,
	\op3ratio, 3,
	\op3atk, 0.01,
	\op3dec, 0,
	\op3suslevel, 0.7,
	\op3rel, 2,
	\op3curve, 4,
	// one-pole coefficient
	\op3coef, 0.5,
	\op3pan, 0,

	// operator 4
	\op4, 0,
	\op4ratio, 5,
	\op4atk, 0.01,
	\op4dec, 0.1,
	\op4suslevel, 0.4,
	\op4rel, 0.1,
	\op4curve, -4,
	// one-pole coefficient
	\op4coef, 0.7,
	\op4pan, 0,

	//////////////////////////////
	// modulators
	// 0pi to 2pi seems to be most useful range
	\m1_1, 0.05pi, //feedback
	\m1_2, 0.2pi,
	\m1_3, 0.1pi,
	\m1_4, 0pi,

	\m2_1, 0pi,
	\m2_2, 0pi, //feedback
	\m2_3, 0.2pi,
	\m2_4, 0pi,

	\m3_1, 0pi,
	\m3_2, 0pi,
	\m3_3, 0pi, //feedback
	\m3_4, 0.3pi,

	\m4_1, 1pi,
	\m4_2, 0.1pi,
	\m4_3, 1pi,
	\m4_4, 0.5pi, //feedback

	\lpf, 2000,
	\hpf, 80
));
)


/////////////////////////////////////////////////////////////////////
// fm7
/////////////////////////////////////////////////////////////////////
(
Pdef(\fm7, Pbind(

	\instrument, \fm7,
	\degree, Pseries(0, 2).fold(0, 8),
	\octave, Pmap(5, 8, 4, 5),
	\scale, [Scale.hexSus, Scale.dorian].pseq.stutter(32),
	\stretch, 0.25,
	\legato, 0.9,
	\rel, 4,
	\suslevel, 0.8,
	\harmonic, [1, 1.5],
	\vel, [1, 0.5],
	\amp, 0.dbamp,

	\op1, 1,
	\op1ratio, 1,

	\op2, 0,
	\op2ratio, 2,
	\op2dec, 0.8,
	\op2suslevel, 1,

	\op3, 0,
	\op3ratio, 0.5,
	//\op3dec, 0.8,
	//\op3suslevel, 0,

	\op4, 0,
	\op4ratio, 2.01,
	//\op4dec, 0.2,
	//\op4suslevel, 0,

	\op5, 0,
	\op5ratio, 2,

	\op6, 0,
	\op6ratio, 2,

	\m1_1, 0, //feedback
	\m1_2, 0.5,
	\m1_3, 0,
	\m1_4, 0,
	\m1_5, 0,
	\m1_6, 0,

	\m2_1, 0,
	\m2_2, 0.1, //feedback
	\m2_3, 1,
	\m2_4, 0,
	\m2_5, 0,
	\m2_6, 0,

	\m3_1, 0,
	\m3_2, 0,
	\m3_3, 0, //feedback
	\m3_4, 0.5,
	\m3_5, 0,
	\m3_6, 0,

	\m4_1, 0,
	\m4_2, 0,
	\m4_3, 0,
	\m4_4, 0.5, //feedback
	\m4_5, 0,
	\m4_6, 0,

	\m5_1, 0,
	\m5_2, 0,
	\m5_3, 0,
	\m5_4, 0,
	\m5_5, 0, //feedback
	\m5_6, 0,

	\m6_1, 0,
	\m6_2, 0,
	\m6_3, 0,
	\m6_4, 0,
	\m6_5, 0,
	\m6_6, 0, //feedback
));
)

