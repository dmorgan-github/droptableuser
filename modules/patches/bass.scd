/////////////////////////////////
// patch
~bass = ProxySpace.new(s);
~bass.quant = 4.0;
~bass.clock = TempoClock.default;

/////////////////////////////////
// sequencer
(~bass[\bass_seq][0] = {
	var trig = \trig.tr;
	var freq = \freq.kr;
	[trig, freq];
});
(~bass[\bass_seq][4] = \set -> Pbind(
	\delta, 4,
	\trig, 1,
	\scale, Scale.kumoi,
	\freq, Pseq(['C1', 'C1', 'C1', 'C1', 'F1', 'F1', 'F1', 'Eb1'].namecps, inf)
))

/////////////////////////////////
// trig
~bass[\basstrig] = {~bass[\bass_seq].kr[0]};
/////////////////////////////////
// freq
~bass[\bassfreq] = {~bass[\bass_seq].kr[1]};

/////////////////////////////////
// amp env
(~bass[\bassenv] = {
	var trig = ~bass[\basstrig];
	var ts = 1;
	var atk = 0.1;
	var sus = 2;
	var rel = 3;
	var curve = 0;
	var ls = 1;
	var env = Env.linen(atk,sus,rel,curve:curve).kr(gate:trig, timeScale:ts, mul:ls);
	env;
});

/////////////////////////////////
// synth
(~bass[\snd][0] = {

	var amp = 0;
	var freq = 432;

	var freq_in = Vibrato.ar(K2A.ar(\freq.kr(freq).lag(\lag.kr(0.0))),
		\vrate.kr(6),
		\vdepth.kr(0.0),
		\vdelay.kr(0),
		\vonset.kr(0),
		\vrateVar.kr(0.04),
		\vdepthVar.kr(0.1)
	);

	var lfo = SinOsc.kr(1/4).range(0.2, 0.7);
	var sig = SinOscFB.ar(freq_in * [1, 2.01], feedback:lfo);

	sig = DFM1.ar(sig, SinOsc.kr([1/4, 1/3]).range(110, 440), 0.3);

	sig = sig * AmpCompA.kr(freq_in) * \amp.kr(amp);

	Splay.ar(sig);
});

4.reciprocal

~bass[\snd].set(\freq, ~bass[\bassfreq], \amp, ~bass[\bassenv], \vdepth, 0.002);

(~bass[\snd][1] = \filter -> {arg in;

	//var drop = LFTri.kr(1/8).range(0, 10);
	//WaveLoss.ar(in, 10);
	//DelayC.ar(in, 1.0, LFNoise0.ar(13).range(0.0, 1.0))
	//var trig = ~bass[\basstrig];
	//var env = Env([1/6, 1/6, 8],[0, 1/4], 24).kr(gate:trig);
	in * LFPulse.kr(8).range(0,1);
})
~bass[\snd].set(\wet1, 1)

(~bass[\snd][2] = \filter -> {arg in;

	/*
	# 1767 C* ChorusI - Mono chorus/flanger
	> a: in (-1 to 1)
	> k: t (ms) (2.5 to 40)
	> k: width (ms) (0.5 to 10)
	> k: rate (Hz) (0 to 5)
	> k: blend (0 to 1)
	> k: feedforward (0 to 1)
	> k: feedback (0 to 1)
	< a: out
	*/
	var sig = LADSPA.ar(1, 1767,
		in,
		\t.kr(30),
		\cwidth.kr(1.5),
		\crate.kr(2.5),
		1,
		\fwd.kr(0.8),
		\fb.kr(0.2)
	);

	LeakDC.ar(sig);
})

~bass[\snd][4] = \filter -> {arg in; JPverb.ar(in, t60:3, size:2)};

~bass[\snd].set(\wet4, 0.5);


/////////////////////////////////
// play
~bass[\snd].gui;
~bass[\snd].play
~bass[\snd].stop
~bass[\snd].vol = 0.3;


