////////////////////////////////
// patch
~fm_bass = ProxySpace.new(s);
~fm_bass.quant = 1.0;
~fm_bass.clock = TempoClock.default;

(
~mods = {arg mod_vals;

	var mods = Array.fill2D(6, 6, 0);
	mod_vals.do({arg val;
		mods[val[0]][val[1]] = val[2]
	});
	mods;
};

~fm_bass[\snd][0] = {

	var algo = 4;

	var trig = \trig.tr;

	var dur = \dur.kr(1);

	var fenvcurve = \fenvcurve.kr(0);

	var freq = Vibrato.ar(K2A.ar(\freq.kr(432).lag(\lag.kr(0.0))),
		\vrate.kr(6),
		\vdepth.kr(0.0),
		\vdelay.kr(0),
		\vonset.kr(0),
		\vrateVar.kr(0.04),
		\vdepthVar.kr(0.1)
	);

	var fenv = Env([1,1,0],[0,dur],fenvcurve);

	var ctrls = [
		[freq * \f0.kr(1), 0, EnvGen.kr(fenv, gate:trig)],
		[freq * \f1.kr(1), 0, EnvGen.kr(fenv, gate:trig)],
		[freq * \f2.kr(1), 0, EnvGen.kr(fenv, gate:trig)],
		[freq * \f3.kr(1), 0, EnvGen.kr(fenv, gate:trig)],
		[freq * \f4.kr(1), 0, EnvGen.kr(fenv, gate:trig)],
		[freq * \f5.kr(1), 0, EnvGen.kr(fenv, gate:trig)]
	];

	var feedback = \fb.kr(0);

	var mods = [
		[ 0, 2, 0, 0, 0, 0 ],
		[ 0, 0, 0, 0, 0, 0 ],
		[ 0, 0, 0, 1, 0, 0 ],
		[ 0, 0, 0, 0, 0, 0 ],
		[ 0, 0, 0, 0, 0, 0 ],
		[ 0, 0, 0, 0, 0, 2 ]
	];

	var sig = FM7.ar(ctrls, mods).slice([0, 2, 4]);

	var env = Env.perc(releaseTime:dur).kr(gate:trig);

	sig = sig + SyncSaw.ar(0.5, freq, mul:0.3);

	sig = sig * AmpCompA.kr(freq) * \amp.kr(0);

	Splay.ar(sig.sum);
})

//[0, 2, 4] -> [

////////////////////////////////
//
(~fm_bass[\snd].set(

	//\trig, 1,

	\f0, 1.01,
	\f1, 4.01,
	\f2, 1.01,
	\f3, 0.5,
	\f4, 2.011,
	\f5, 2.01,

	\f0amp, 1,
	\f1amp, 1,
	\f2amp, 1,
	\f3amp, 1,
	\f4amp, 1,
	\f5amp, 1,

	\fb, 1,

	\amp, 0.1,
));

~fm_bass[\snd].unset(\amp)

(~fm_bass[\snd][4] = \set -> Pbind(
	\args, #[\freq, \lag],
	\scale, Scale.zhi,
	\degree, Pwalk([1,3,2,4], Pseq([1], inf), Pseq([1, -1], inf), 0),
	\octave, Pseq([3,3,3,4,3,4,3,4], inf),
	\lag, 0.012,
));

(~fm_bass[\snd][6] = \set -> Pbind(
	\args, #[\trig, \dur, \amp],
	\trig, 1,
	\beatDur, Pfunc({thisThread.clock.beatDur}),
	\delta, Pseq([1,1,0.5,0.5,1,1,1,1,0.5,0.5], inf),// Pwrand([1, 0.25], [0.8, 0.2], inf),
	\dur, Pkey(\delta) * Pkey(\beatDur) * Pseq([1,1,1,2,1,2], inf),
	\amp, 0.2
));

(~fm_bass[\snd][8] = \filter -> {arg in;
	var sig = RunningSum.rms(in, 30);
	sig = LeakDC.ar(sig);
	sig = DFM1.ar(sig, SinOsc.kr(8).range(110, 840), SinOsc.kr(1/8).range(0.1,0.7));
})

(~fm_bass[\snd].filter(10, {arg in;
	JPverb.ar(in);
}))

~fm_bass[\snd].set(\wet8, 1, \wet10, 0.2)


TempoClock.default.tempo_(120/60)
~fm_bass[\snd].gui
~fm_bass[\snd].play
~fm_bass[\snd].stop





App.recordWorkspace("ws2");
s.stopRecording

Ndef().filter