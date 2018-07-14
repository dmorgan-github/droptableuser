
~p1 = ProxySpace.new(s);
(~p1[\snd][0] = {

	var trig = \trig.tr;
	var freq = \freq.kr(432);
	var sig = Pluck.ar(WhiteNoise.ar(0.1), trig, freq.reciprocal, freq.reciprocal, 10, coef:0.3);
	var env = Env.perc.kr(gate:trig);
	var env2 = Env.linen.kr(gate:trig);

	var sig2, sig3, sig4, sig5;

	sig = sig + Saw.ar(freq * 0.5, mul:0.4) * env;

	sig2 = DFM1.ar(sig, Env([4440,4440,220],[0,0.5],-4).kr(gate:trig), 0.7);

	sig3 = SVF.ar(sig, Env([220,220,2220],[0,0.05],-4).kr(gate:trig), 0.8);

	sig4 = PMOsc.ar(freq, freq * 2.3, 3);

	sig5 = Resonz.ar(WhiteNoise.ar, freq, 0.1) * 4;

	sig = sig + (sig2 * env2 * 0.5) + (sig3 * env2 * 0.5) + (sig4 * 0.1) + sig5;

	sig!2 * env;
})

(~p1[\snd][4] = \set -> Pbind(
	\trig, 1,

	\freq, Pwalk(
		[60, 64, 67, 72, 76, 79, 84].midicps,
		Pseq([1], inf),
		Pseq([1, -1], inf),
		0
	),
	\delta, 0.25
))


~p1[\snd][6] = \filter -> {arg in; FbC({arg fb; fb * 0.7 + in}, 0.4)};

~p1[\snd][8] = \filter -> {arg in; JPverb.ar(in)};

~p1[\snd].set(\wet8, 0.5, \wet10, 0.4)

~p1[\snd].gui
~p1[\snd].play(fadeTime:5);
~p1[\snd].stop(fadeTime:10);

~p1[\snd].vol = 0.1;

App.recordWorkspace("ws1");
s.stopRecording