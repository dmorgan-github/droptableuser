(
SynthDef(\pad, {

	var freq = Vibrato.kr(\freq.kr(432), \vrate.kr(6), \vdepth.kr(0.01));

	var env = Env.adsr(
		\atk.kr(0.01),
		\decay.kr(0.3),
		\susLevel.kr(0.5),
		\rel.kr(1),
		curve:[\curve.kr, \curve.kr.neg]
	).kr(gate:\gate.kr(1), doneAction:Done.freeSelf);

	var sig = {
		[
			{
				var myfreq = freq * [1, 2.01];
				var sig = Saw.ar(myfreq);
				sig = RLPF.ar(sig, SinOsc.kr(1/8).exprange(1000,4000), 0.1).tanh;
				sig * AmpCompA.kr(myfreq);
			},
			{
				var myfreq = freq * [1, 2.01, 4.01];
				var sig = Gendy1.ar(minfreq:myfreq, maxfreq:myfreq);
				sig = DFM1.ar(sig, SinOsc.kr(1/7).exprange(440, 4000), XLine.kr(0.1, 0.9, 2));
				sig * AmpCompA.kr(myfreq);
			},
			{
				var sig = PinkNoise.ar;
				sig
			}
		] * [0.5, 0.4, 0.2].normalizeSum
	}.();

	sig = LPF.ar(sig, 1080);
	sig = BLowShelf.ar(sig, 200, 0.1);
	sig = sig.sum * env * AmpCompA.kr(freq) * \amp.kr(-20.dbamp);
	sig = DelayC.ar(sig, 0.2, [0.01, 0.05]);
	sig = SoftClipAmp8.ar(sig, 3);
	sig = Splay.ar(sig);
	Out.ar(\out.kr(0), sig);

}).add;
)

(
var seq = [
	[-14, 0, 2, 6],
	[-15, 1, 3, 7, 10]
];
Pbindef(\pad,
	\instrument, \pad,
	\root, 2,
	\scale, Scale.minor,
	\octave, 5,
	\degree, Pseq(seq, inf),
	\sustain, 4,
	\dur, 8,
	\atk, 1,
	\susLevel, 0.7,
	\amp, -12.dbamp
)
)

~p[\pad][0] = Pbindef(\pad);
~p[\pad].play;
~p[\ppad].stop;

(
~p[\pad].filter(10, {arg in;
	var sig = FbC({arg fb; fb * 0.3 + in}, [3/8, 5/8]) + in;
	JPverb.ar(sig, 10, 0, 5).tanh + sig;
})
)

Pbindef(\pad).play;
Pbindef(\pad).stop;