~p = ~p ? ProxySpace.new(s, \p);

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
	\delta, 8,

	\scale, Scale.locrian,
	\degree, Pseq([
		Pseq(circle[\first], 16),
		Pshuf(circle[\fifth], 16),
		Pseq(circle[\second], 16),
		Pshuf(circle[\seventh], 16)
	], inf),
	\octave, 5,
	\vdepth, 0.005,

	[\c0env_ts, \c1env_ts, \c2env_ts], #[1,2,3].normalizeSum,

	\c0amp, 1,

	\c1, Pwhite(2.0, 2.1, inf),
	\c1env, [Env( {rrand(0.0, 1.0)}.dup(5), { rrand(0.0, 1) }.dup(4).normalizeSum, [-4,4,-12,12,-4])],
	\c1amp, 0.3,

	\c2, 4,
	\c2env, [Env( {rrand(0.0, 1.0)}.dup(5), { rrand(0.0, 1) }.dup(4).normalizeSum, [-4,4,-12,12,-4])],
	\c2amp, 0.5,

	[\m0_0, \m0_1, \m0_2], Ptuple([
		Pseq([0, 0.1, 0.5, 0.2], inf),
		Pwhite(0.0, 0.2, inf),
		Prand([0, 0.1, 0.5, 0.2])
	], inf).collect(_.normalizeSum) * 0.3,

	/*
	[\m1_0, \m1_1, \m1_2], Ptuple([
		Pseq([0, 0.1, 0.5, 0.2], inf),
		Pwhite(0.0, 0.2, inf),
		Prand([0, 0.1, 0.5, 0.2])
	], inf).collect(_.normalizeSum) * 0.1,
	*/


	[\chan0, \chan1, \chan2, \chan3, \chan4, \chan5], #[1,1,1,0,0,0],

	\amp, 0.3
))

~p[\fm7_mono].play(out:0);
~p[\fm7_mono].stop;


Osc





