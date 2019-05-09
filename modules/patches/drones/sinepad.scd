(
SynthDef(\pad, {

	var freq = Vibrato.kr(\freq.kr(432), \vrate.kr(0.01), \vdepth.kr(0.1));

	var env = Env.adsr(
		\atk.kr(0.01),
		\decay.kr(0.3),
		\susLevel.kr(0.5),
		\rel.kr(1),
		curve:\sqr
	).kr(gate:\gate.kr(1), doneAction:Done.freeSelf);

	var sig = {
		[
			{
				var myfreq = freq * [1, 1.01, 5.midiratio];
				var sig = SinOsc.ar(myfreq);
				sig * AmpCompA.kr(myfreq);
			},
			{
				PinkNoise.ar
			}
		] * [1, 0.05].normalizeSum
	}.();

	sig = DelayC.ar(sig, 0.2, [0.01, 0.05]) + sig;
	sig = sig.sum * env * AmpCompA.kr(freq) * \amp.kr(-20.dbamp);
	sig = SoftClipAmp8.ar(sig, 2);
	sig = LPF.ar(sig, 1080);
	sig = Splay.ar(sig);
	Out.ar(\out.kr(0), sig);

}).add;
)

(
var seq = [
	[0, 4],
	[1, 6],
	[-3, 1]
];
Pbindef(\pad,
	\instrument, \pad,
	\root, 2,
	\scale, Scale.zhi,
	\octave, 5,
	\degree, Pseq(seq, inf),
	\sustain, 4,
	\dur, 8,
	\atk, 1,
	\susLevel, 0.7,
	\amp, -25.dbamp
)
)

~p[\pad][0] = Pbindef(\pad);
~p[\pad].play;
~p[\pad].stop(fadeTime:10);

(
~p[\pad].filter(10, {arg in;
	var sig = in;//FbC({arg fb; fb * 0.3 + in}, [3/8, 5/8]) + in;
	sig.blend(JPverb.ar(sig, 10, 0, 5), 0.5);// * 0.5 + sig;
})
)



Pbindef(\pad).play;
Pbindef(\pad).stop;