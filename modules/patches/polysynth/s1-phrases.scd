(
SynthDef(\space1, {

	var freq = Vibrato.kr(\freq.kr(432), 6, 0.01);
	var sig = SinOscFB.ar(freq.lag(0.1), Rand(0.4, 0.7));
	var env = Env.perc(curve:\sqr).kr(gate:1, doneAction:Done.freeSelf);

	sig = [
		VarSaw.ar(freq * 17.midiratio, width:SinOsc.kr(1).range(0.4, 0.6)) * Env.perc(0.1).kr(gate:1) * 0.5,
		RLPF.ar(
			SoftClipAmp8.ar(sig, 4) * LFPulse.kr(10),
			XLine.kr(8200, 1200, Rand(0.1, 2)),
			Rand(0.1, 0.5)
		) * 0.5,
		FreqShift.ar(sig, [-3, 3]),
		(sig * 2).tanh
	];

	sig = Splay.ar(sig) * env * AmpCompA.kr(freq) * \amp.kr(-6.dbamp);
	Out.ar(\out.kr(0), sig);

}).add;
)

(
Pdef(\space1, Pbind(
	\instrument, \s1,
	\degree, Pwhite(0, 7),
	\octave, Prand([4, 5], inf),
	\amp, Pwhite(0.1, 0.3) * 1
))
)