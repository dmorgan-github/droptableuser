
(
SynthDef(\n3, {

	var trig = \trig.tr;
	var freq = \freq.kr(1220);
	var rq = \rq.kr(0.02);
	var sig = WhiteNoise.ar * Env([5,5,0],[0,0.01],0).kr(gate:trig);
	sig = BPF.ar(sig, freq, rq);
	//sig = Decimator.ar(sig, 44100/10, 8);
	//sig = SmoothDecimator.ar(sig, 44100/30, 0.001);
	//sig = Disintegrator.ar(sig, SinOsc.kr(2).range(0.1,1.0), 1);
	sig = sig * \amp.kr(-20.dbamp);
	sig = Pan2.ar(sig, \pan.kr(0));
	Out.ar(\out.kr(0), sig);

}).add;
)

(
Pdef(\n3, Pmono(\n3,
	\freq, Pseries(520, 110, 20),
	\rq, Pwhite(0.01, 0.1),
	\dur, 1/32,
	\amp, -12.dbamp
))
)

Pdef(\n3).play
