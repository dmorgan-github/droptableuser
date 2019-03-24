TempoClock.default.tempo_(60/60);

/////////////////////////////////////////
// drone
~p[\drone].clear;
(
~p[\drone][0] = {

	var hi = Demand.kr(Impulse.kr(8.reciprocal), 0, Dseq(['A2', 'G2', 'E3', 'D3'].namecps, inf));
	var lo = Demand.kr(Impulse.kr(18.reciprocal), 0, Dseq(['D1', 'A0', 'E1', 'B0'].namecps, inf));
	var freqs = [lo, 'D2'.namecps, 'B2'.namecps, hi];
	var freq = Vibrato.kr(freqs, \vrate.kr(0.02), \vdepth.kr(0.01));

	var env = Env.adsr(
		\atk.kr(1),
		\decay.kr(0.3),
		\susLevel.kr(0.7),
		\rel.kr(1),
		curve:[\curve.kr, \curve.kr.neg]
	).kr(1);

	var sig = [
		{
			var myfreq = freq * [1, 2.01, 4.001];
			var sig = Pulse.ar(freq * [1, 2.01], width: SinOsc.kr(1/8).range(0.4,0.6));
			sig = RLPF.ar(sig, SinOsc.kr(1/8).range(440, 1440), 0.7);
			sig = sig * AmpCompA.kr(myfreq);
			Splay.ar(sig) * SinOsc.kr(1/10).range(0.5, 1);
		},
		{
			var myfreq = freq * [1, 1.01, 2.001];
			var sig = Gendy1.ar(minfreq:myfreq, maxfreq:myfreq);
			sig = RLPF.ar(sig, SinOsc.kr(1/16).range(220, 1000), 1);
			sig = sig * AmpCompA.kr(myfreq);
			Splay.ar(sig) * SinOsc.kr(1/8).range(0.7, 1);
		},
		{
			var sig = PinkNoise.ar;
			sig;
		}
	].collect(_.value) * [0.2, 0.8, 0.05].normalizeSum;

	sig = sig.flatten;
	sig = sig.sum;

	sig = JPverb.ar(sig, 10, 0, 5).tanh + sig;
	sig = Splay.ar(sig) * env * \amp.kr(-6.dbamp);
};
)

~p[\drone].play(vol:0.5);
~p[\drone].stop(fadeTime:10);

~p[\fx2].clear;
(~p[\fx2][0] = {

	var in = ~p[\drone].ar;
	var rate = [2,4.001];
	var sig = Greyhole.ar(in, modDepth:0.7);
	var trig = Impulse.kr(rate);
	var env = Env.perc(releaseTime:0.4).kr(gate:trig);
	sig = PitchShift.ar(in, 0.5, [12.midiratio]);
	sig = sig * env;
	sig = RLPF.ar(sig, Env([4000, 4000, 220], [0, rate.reciprocal], LFNoise2.kr(1/8).range(-4,4)).kr(gate:trig), 0.2);
	sig = FbC({arg fb; fb * 0.7 + sig}, [3/8, 5/8]) * 0.4 + sig;
	sig = JPverb.ar(sig, 8, 0, SinOsc.kr(1/64).range(1,2)) * 0.7 + sig;
	sig = FreqShift.ar(sig, [-3,3]);
	sig = BLowShelf.ar(sig, 200, 1, -20);
	Splay.ar(sig, spread:1);
})
~p[\fx2].play(vol:0.8, fadeTime:0);
~p[\fx2].stop;

~p[\fx3][0] = {
	var in = ~p[\fx2].ar;
	WaveLoss.ar(in, 30);
}

~p[\fx3].play(vol:0.5, fadeTime:8);
~p[\fx3].stop(fadeTime:8);

(
Routine({

	App.saveWorkspace("ws18", rec:true);

	"start".debug;
	~p[\drone].play(fadeTime:0, vol:1);
	~p[\fx2].play(fadeTime:48, vol:1);

	128.wait;

	"end".debug;

	~p[\drone].stop(fadeTime:16);
	~p[\fx2].stop(fadeTime:32);

	42.wait;
	s.stopRecording

}).play;
)


