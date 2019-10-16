(
SynthDef(\pad2, {

	var freq = Vibrato.kr(\freq.kr(432), \vrate.kr(0.005), \vdepth.kr(0.001));

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
				var sig = [
					Pulse.ar(myfreq, width: SinOsc.kr(1/8).exprange(0.4,0.6)),
					VarSaw.ar(myfreq * 2, 0, width: SinOsc.kr(1/4).exprange(0.4, 0.7))
				].sum;
				sig = RLPF.ar(sig, 4000, 0.2).tanh;
				sig * AmpCompA.kr(myfreq);
			},
			{
				var myfreq = freq * [1, 2.01, 4.01];
				var sig = Gendy1.ar(minfreq:myfreq, maxfreq:myfreq);
				sig = DFM1.ar(sig, 4000, 0.7);
				sig * AmpCompA.kr(myfreq);
			},
			{
				var sig = PinkNoise.ar;
				sig
			}
		] * [0.5, 0.4, 0.2].normalizeSum
	}.();

	sig = LPF.ar(sig, 1080);
	sig = BLowShelf.ar(sig, 200, 1, -20.dbamp);
	sig = Splay.ar(sig) /*sig.sum*/ * env * AmpCompA.kr(freq) * \amp.kr(-20.dbamp);
	sig = DelayC.ar(sig, 0.2, [0.01, 0.05]);
	sig = SoftClipAmp8.ar(sig, 3);
	sig = Splay.ar(sig);
	Out.ar(\out.kr(0), sig);

}).add;
)

(
var seq = [
	[-7, 0, 2, 9]
];
Pbindef(\pad2,
	\instrument, \pad2,
	\root, 2,
	\scale, Scale.zhi,
	\octave, 5,
	\degree, Pseq(seq, inf),
	\legato, 16,
	\dur, 16,
	\atk, 1,
	\susLevel, 0.7,
	\amp, -30.dbamp
)
)

~p[\pad2].clear;
~p[\pad2][0] = Pbindef(\pad2);
~p[\pad2].play(vol:1);
~p[\pad2].stop(fadeTime:10);

(
~p[\pa2].filter(10, {arg in;
	var sig = in;//FbC({arg fb; fb * 0.3 + in}, [3/8, 5/8]) + in;
	JPverb.ar(sig, 10, 0, 5).tanh + sig;
})
)


