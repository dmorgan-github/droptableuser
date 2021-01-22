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
