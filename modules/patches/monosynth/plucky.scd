

~p[\pluck].clear;
~p[\pluck].play;
~p[\pluck].stop;
(
~p[\pluck][0] = {

	var noise = WhiteNoise.ar(0.1);
	var trig = \trig.tr;
	var freq = \freq.kr(432);
	var sig = Pluck.ar(noise, trig, freq.reciprocal, freq.reciprocal, 10, coef:0.4);// + (Pulse.ar(freq) * 0.05);
	var env = Env.perc.kr(gate:trig);
	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(-6.dbamp);
	Splay.ar(sig);
})
)
(~p[\pluck][2] = \set -> Pbind(
	\trig, 1,
	\degree, Ppoisson(1, inf),
	\octave, Pbjorklund(5, 8, inf).collect({arg val; if (val == 0) {5}{6}}),
	\mtranspose, Pstutter(128, Pseq([0, 5, 7, 2], inf)),
	\amp, 0.dbamp,
	\dur, 0.25,
	\amp, Pwhite(-6.dbamp, -3.dbamp, inf)
))


~p[\pluck].scope



s.prepareForRecord(Document.current.path ++ ".aiff", 2);
s.record;
s.stopRecording

