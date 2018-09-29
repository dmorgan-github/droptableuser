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
	) * [1, 1.01];// LFNoise2.kr(0.01).range(-5,5);

	var dur = 4;

	var osc1 = {
		var ctrls = [
			[freq * 1,            0, Env([0,1,0],[1, dur], -4).kr(gate:trig)],
			[freq * 1,            0, 1],
			[freq * 0.5,          0, Env([0,1,0],[0.01, dur * 2], 0).kr(gate:trig)],
			[freq * 1,            0, 0],
			[freq * 1,            0, 0],
			[freq * 1,            0, 0]
		];

		var mods = [
			[0.1, 0,    0.3,  0,    0,0],
			[0,   0,    0,    0,    0,0],
			[0,   0,    0,    0,    0,0],
			[0,   0,    0,    0,    0,0],
			[0,   0,    0,    0,    0,0],
			[0,   0,    0,    0,    0,0]
		] * 2pi;

		var sig = FM7.ar(ctrls, mods) * [1,0,0,0,0,0,0];
		(sig * \gain.kr(1.5)).tanh;
	};

	var sig = [
		osc1.().flatten.sum,
	].sum;

	sig = sig * AmpCompA.kr(freq) * \amp.kr(0.3);

	sig = sig + DelayC.ar(sig, 0.05, SinOsc.kr([1/16,1/8]).range(0.001, 0.005));

	Splay.ar(sig);
});

(
var circle = Library.at(\circle);
~p[\fm7_mono][1] = \set -> Pbind(

	\trig, 1,
	\delta, 4,

	\scale, Scale.ritusen,
	\degree, Pstutter(2, Pseq([0, -2], inf)),
	\octave, 4,
	\vdepth, 0.005,
	\amp, -20.dbamp
))

~p[\fm7_mono].play(out:0);
~p[\fm7_mono].stop;



