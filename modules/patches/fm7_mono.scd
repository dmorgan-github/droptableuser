~p = ~p ? ProxySpace.new(s, \p);

//////////////////////////////////////////////
// patch
(
var defaultAmp = 0.5;
var defaultAtk = 0.001;
var defaultSusLevel = 0.7;
var defaultDecay = 0.05;
var defaultSus = 0.8541;
var defaultRel = 0.0949;
var controllerEnv = Env([0,1,defaultSusLevel,defaultSusLevel,0],[defaultAtk,defaultDecay,defaultSus,defaultRel],\sin);

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

	sig = sig * AmpCompA.kr(freq) * \amp.kr(defaultAmp);

	Pan2.ar(Mix.ar(sig), \pan.kr(0));
});

(~p[\fm7_mono][1] = \set -> Pbind(
	\trig, 1,
	\delta, Pseq([0.0625, 0.125, 0.25, 0.5, 4 ], inf),

	\scale, Scale.lydian,
	\degree, Pwhite(0, 4, inf),
	\octave, 5,
	\vdepth, 0.005,

	\c0env_ts, 1,

	\c1, 12.1,
	\c1env, [Env([1,0.75,0.5,0.25,0],[0.25,0.25,0.25,0.25],\lin)],
	\c1env_ts, 0.01,

	\m0_0, 0.1,
	\m0_1, 0.15,

	\m1_0, 0.4,

	[\chan0, \chan1, \chan1, \chan2, \chan4, \chan5], #[1,0,0,0,0,0]
))

(~p[\fm7_del] = {
	var in = \in.ar([0,0]);
	var fx = FbC({arg fb; fb * 0.3 + RLPF.ar(in, 2200, 0.5)}, 3/4);
	fx = FbC({arg fb; fb * 0.3 + PitchShift.ar(in, pitchRatio:2)}, [3/4, 5/4]);
	fx
})

(~p[\fm7_grey] = {
	var in = \in.ar([0,0]);
	var fx = Greyhole.ar(in, 5, size:5);
	fx;
});

(~p[\fm7_res] = {

	var in = \in.ar([0,0]);

	var detune = \detune.kr(0);

	var numFreqs = 6;

	var freq_in = Vibrato.ar(K2A.ar(\freq.kr(432).varlag(\lag.kr(0.0))),
		\vrate.kr(6),
		\vdepth.kr(0.0),
		\vdelay.kr(0),
		\vonset.kr(0),
		\vrateVar.kr(0.04),
		\vdepthVar.kr(0.1)
	);

	var ffreqs = (0..numFreqs-1).collect({arg i;
		(\f ++ i).asSymbol.kr(1);
	}) + detune;

	var amps = (0..numFreqs-1).collect({arg i;
		(\a ++ i).asSymbol.kr(1/numFreqs);
	});

	var rings = (0..numFreqs-1).collect({arg i;
		(\r ++ i).asSymbol.kr(1);
	});

	var sig = DynKlank.ar(`[freq_in * ffreqs, amps, rings], in);

	sig = sig * AmpCompA.kr(freq_in) * \amp.kr(0);

	Mix.ar(sig)!2;
})

(~p[\lfo1] = {
	SinOsc.kr(1/16).range(0, 1) * 0.1;
})

(~p[\lfo2] = {
	SinOsc.kr(1/32).range(8, 13);
})

(~p[\fm7_res].set(

	\freq, 432,

	\f0, 1.02340,
	\f1, 3.2,
	\f2, 5.234,
	\f3, 9.123,
	\f4, 11.23,
	\f5, ~p[\lfo2], //13.93930,

	\detune, 0.001,

	\r0, 1,
	\r1, 1,
	\r2, 1,
	\r3, 1,
	\r4, 1,
	\r5, 1,

	\vdepth, 0.01,
	\lag, 0.1,
	\amp, ~p[\lfo1]
))


~p[\fm7_mono].play;
~p[\fm7_mono].stop;

~p[\fm7_del] <<> ~p[\fm7_mono];
~p[\fm7_del].vol = 1
~p[\fm7_del].play(out:2);
~p[\fm7_del].stop;

~p[\fm7_grey] <<> ~p[\fm7_del];
~p[\fm7_grey].vol = 1;
~p[\fm7_grey].play(out:4);
~p[\fm7_grey].stop;

~p[\fm7_res] <<> ~p[\fm7_grey];
~p[\fm7_res].play(out:6);
~p[\fm7_res].stop;





