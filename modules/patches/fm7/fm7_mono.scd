//////////////////////////////////////////////
// patch
(
~p[\fm7_mono][0] = {

	var trig = \trig.tr(0);

	var freq = Vibrato.ar(K2A.ar(\freq.kr(432)),
		\vrate.kr(6),
		\vdepth.kr(0.0),
		\vdelay.kr(0),
		\vonset.kr(0),
		\vrateVar.kr(0.04),
		\vdepthVar.kr(0.1)
	);

	var controllerEnv = Env([0,1,0.7,0.7,0],[0.001,0.05,0.8541,0.0949],\sin);

	var ctrls = Array.fill(6, {arg i;
		var env = ('c' ++ i ++ 'env').asSymbol.kr(controllerEnv.asArray);
		var amp = ('c' ++ i ++ 'amp').asSymbol.kr(1);
		var ts = ('c' ++ i ++ 'env_ts').asSymbol.kr(1);
		var envgen = EnvGen.kr(env, gate:trig, levelScale:amp, timeScale:ts);
		[freq * ('c' ++ i).asSymbol.kr(1) + LFNoise2.kr(0.01).range(-5,5), 0, envgen]
	});

	var mods = Array.fill2D(6, 6, {arg r, c;
		var key = ('m' ++ r ++ '_' ++ c);
		key.asSymbol.kr(0);
	}) * 2pi; // in radians

	var sig = FM7.ar(ctrls, mods) * (0..5).collect({arg i; ('chan' ++ i).asSymbol.kr(0)});

	sig = sig * AmpCompA.kr(freq) * \amp.kr(0.3);

	Pan2.ar(Mix.ar(sig), \pan.kr(0));
});

(
var circle = Library.at(\circle);
~p[\fm7_mono][1] = \set -> Pbind(

	\trig, 1,
	\delta, 4,

	\scale, Scale.major,
	\degree, Pseq([2,1], inf),
	\octave, 3,
	\vdepth, 0.005,

	[\c0env_ts, \c1env_ts, \c2env_ts, \c3env_ts, \c4env_ts, \c5env_ts], #[1,2,3,4,5,6].normalizeSum,

	\c0, 0,
	\c0env, [Env([0,1,0.7,0.7,0],[0.001,0.05,0.8541,0.0949],\sin)],
	\c0amp, 0.5,
	\c0env_ts, 1,

	\c1, 0.5,
	\c1env, [Env([0,1,0.7,0.7,0],[0.001,0.05,0.8541,0.0949],\sin)],
	\c1amp, 0.3,
	\c1env_ts, 1,

	\c2, 2,
	\c2env, [Env([0,1,0.7,0.7,0],[0.001,0.05,0.8541,0.0949],\sin)],
	\c2amp, 0.5,
	\c2env_ts, 1,

	\c3, 2,
	\c3env, [Env([1,0.75,0.5,0.25,0],[0.25,0.25,0.25,0.25],\sin)],
	\c3amp, 0.5,
	\c3env_ts, 1,

	\c4, 2,
	\c4env, [Env([1,0.75,0.5,0.25,0],[0.25,0.25,0.25,0.25],\sin)],
	\c4amp, 0.5,
	\c4env_ts, 1,

	\c5, 1,
	\c5env, [Env([1,0.75,0.5,0.25,0],[0.25,0.25,0.25,0.25],\sin)],
	\c5amp, 0.5,
	\c5env_ts, 1,

	\m0_0, 0.1, \m0_1, 0.1, \m0_2, 0.1, \m0_3, 0.1, \m0_4, 0.1, \m0_5, 0.5,

	\m1_0, 0.1, \m1_1, 0.1, \m1_2, 0.1, \m1_3, 0.1, \m1_4, 0.1, \m1_5, 0.1,

	\m2_0, 0, \m2_1, 0,	\m2_2, 0, \m2_3, 0, \m2_4, 0, \m2_5, 0,

	\m3_0, 0, \m3_1, 0, \m3_2, 0, \m3_3, 0, \m3_4, 0, \m3_5, 0,

	\m4_0, 0, \m4_1, 0, \m4_2, 0, \m4_3, 0, \m4_4, 0, \m4_5, 0,

	\m5_0, 0.1, \m5_1, 0, \m5_2, 0, \m5_3, 0, \m5_4, 0, \m5_5, 0,

	[\chan0, \chan1, \chan2, \chan3, \chan4, \chan5], #[1,1,1,0,0,0],

	\amp, 0.5
))

~p[\fm7_mono].play(out:0);
~p[\fm7_mono].stop;




~fm7ui.(~p[\fm7_mono])


