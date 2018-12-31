~p[\pluck].clear;
~p[\pluck].play;
~p[\pluck].stop;
(
~p[\pluck][0] = {

	var noise = BrownNoise.ar(0.8);
	var trig = \trig.tr;
	var freq = Vibrato.kr(\freq.kr(432), \rate.kr(6), \depth.kr(0.001));
	var sig = Pluck.ar(noise, trig,
		freq.reciprocal,
		freq.reciprocal,
		SinOsc.kr(1/32).range(0.5, 2),
		coef:LFTri.kr(1/64).range(0.1, 0.4)
	);
	var env = Env.perc.kr(gate:trig);
	//sig = RLPF.ar(sig, 2200, 0.6);

	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(-6.dbamp);
	sig = LeakDC.ar(sig);
	Splay.ar(sig, 1, 1, 0);
})
)
(~p[\pluck][2] = nil\set -> Pbind(
	\trig, 1,
	\degree, Ppoisson(1, inf),
	\root, 0,
	\scale, Scale.minorPentatonic,
	\octave, Pbjorklund(5, 8, inf).collect({arg val; if (val == 0) {5}{6}}),
	\mtranspose, Pstutter(128, Pseq([0, 5, 3, 2], inf)),
	\dur, 0.25,
	\amp, Pwhite(-6.dbamp, -3.dbamp, inf) * 2
))



(
var node = ~p[\pluck].quant_(0);
Pdef(\pluck, {arg out = 0;
	node.play(fadeTime:0, out:out);
	Pbind(\type, \set,
		\id, Pfunc({node.nodeID}),
		\args, #[\trig, \amp, \freq],
		\trig, 1,
		\degree, Ppoisson(1, inf),
		\root, 0,
		\scale, Scale.minorPentatonic,
		\octave, Pbjorklund(5, 8, inf).collect({arg val; if (val == 0) {5}{6}}),
		\mtranspose, Pstutter(128, Pseq([0, 5, 3, 2], inf)),
		\dur, 0.25,
		\amp, Pwhite(-6.dbamp, -3.dbamp, inf) * 2
	)
}).quant_(0)
)

Pdef(\pluck).play;


s.prepareForRecord(Document.current.path ++ ".aiff", 2);
s.record;
s.stopRecording
