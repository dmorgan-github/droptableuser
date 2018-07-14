/////////////////////////////////
// patch
~bass = ProxySpace.new(s);
~bass.quant = 4.0;
~bass.clock = TempoClock.default;

/////////////////////////////////
// synth
(~bass[\snd][0] = {

	var trig = \trig.tr;

	var trig2 = \trig2.tr;

	var freq_in = Vibrato.ar(K2A.ar(\freq.kr(432).lag(\lag.kr(0.0))),
		\vrate.kr(6),
		\vdepth.kr(0.0),
		\vdelay.kr(0),
		\vonset.kr(0),
		\vrateVar.kr(0.04),
		\vdepthVar.kr(0.1)
	);

	var lfo = SinOsc.kr(1/4).range(0.2, 0.7);

	var sig = SinOscFB.ar(freq_in * [1, 2.01], feedback:lfo);

	var env = Env.linen(0.01,2,3,curve:0).kr(gate:trig);

	var env2 = Env.perc(attackTime:0.01,releaseTime:\dur.kr(1/8)).kr(gate:trig2);
	// Env([0,1,0],[0,\dur.kr(1/8)], -1).kr(gate:trig2);

	sig = DFM1.ar(sig, 1200, \res.kr(0.7), inputgain:1);

	//sig = sig + PMOsc.ar(freq_in, freq_in * 1.1, LFDNoise3.kr(5).range(6,10), mul:0.3);// * //;// * Env.
	//Env.xyc({ [1.0.rand, 1.0.rand, -4.rand2] } ! 16, \exp).kr(gate:trig).range(0,1);

	//Shaper.ar(bufnum, audio);

	sig = sig * env * AmpCompA.kr(freq_in) * \amp.kr(0.1);

	sig = sig * max(env2, \switch.kr(0));

	Splay.ar(sig);
});

(~bass[\snd][2] = \set -> PatternProxy(Pbind(
	\delta, Pseq([1,1,14], inf),
	\trig, 1,
	\freq, Pseq([ 'C1', 'D1'].namecps, inf),
	//Pseq(['C1', 'C1', 'F1', 'F1', 'F1', 'Eb1','C1', 'C1'].namecps, inf), // * Pwrand([1, 2], [0.9, 0.1], inf),
	//Pseq(['C1', 'C1', 'C1', 'C1', 'F1', 'F1', 'F1', 'Eb1'].namecps, inf),
	\amp, 0.1
)))
(~bass[\snd][4] = \set -> Pbind(
	\args, #[\trig2, \switch, \dur],
	\trig2, 1,
	\delta, Prand([1, 1, 1/2, 1/2, 1/2, 1/2], inf),
	\dur, 0.8,
	\switch, 1,
))

(~bass[\snd][8] = \filter -> {arg in;
	Disintegrator.ar(in, 0.8, 0.2)
})

(~bass[\snd][10] = \filter -> {arg in;

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

~bass[\snd][12] = \filter -> {arg in; JPverb.ar(in, t60:1, damp:0.5, size:1)};

~bass[\snd].set(\wet8, 0.4, \wet10, 0.6, \wet12, 0.3)
~bass[\snd].set(\wet8, 0.1, \wet10, 0.5, \wet12, 0.5)

/////////////////////////////////
// play
~bass[\snd].gui;
~bass[\snd][2].value.reset;
~bass[\snd].play(fadeTime:10);
~bass[\snd].stop(fadeTime:8);
~bass[\snd].vol = 0.5

