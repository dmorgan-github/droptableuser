~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;

/////////////////////////////////
// synth
(~p[\bass][0] = {

	var trig = \trig.tr;

	var freq_in = Vibrato.ar(K2A.ar(\freq.kr(432).lag(\lag.kr(0.0))),
		\vrate.kr(6),
		\vdepth.kr(0.0),
		\vdelay.kr(0),
		\vonset.kr(0),
		\vrateVar.kr(0.04),
		\vdepthVar.kr(0.1)
	) + LFNoise2.kr(0.01).range(-5,5);

	var osc1 = Saw.ar(freq_in) * \osc1.kr(0.1);

	var osc2 = SinOsc.ar(freq_in, mul:1) * \osc2.kr(0.3);

	var osc3 = VarSaw.ar(freq_in, width:\width.kr(0.5)) * \osc3.kr(0.5);

	var env = Env.linen(\atk.kr(0.01), \sus.kr(2), \rel.kr(3), curve:\curve.kr(-4)).kr(gate:trig);

	var sig = [osc1, osc2, osc3];

	var ffreq = \ffreq.kr(2200);

	sig = RLPF.ar(sig, env.range(ffreq/2, ffreq), \rq.kr(1));

	sig = sig * env * AmpCompA.kr(freq_in) * \amp.kr(0.1);

	Pan2.ar(sig.sum, \pan.kr(0));
});

(~p[\bass][2] = \set -> Pbind(
	\trig, 1,
	\delta, 0.25,
	\beatDur, Pfunc({thisThread.clock.beatDur}),
	\atk, 0.01,
	\sus, 0.0,
	\rel, 0.19,

	\freq, Pseq([ 'C1' ].namecps, inf),

	\width, 0.5,
	\ffreq, 1000,
	\rq, 1,

	\amp, 1,
	[\osc1, \osc2, \osc3], #[0.3, 0.5, 0.4].normalizeSum
))

~p[\bass][8] = nil
(~p[\bass].filter(8, {arg in;
	//Disintegrator.ar(in, 0.5, 0)
	(in * 5).tanh;
}).set(\wet8, 0.1))

~p[\bass][10] = nil

(~p[\bass].filter(10, {arg in;

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

}).set(\wet10, 0.6))

~p[\bass].filter(12, {arg in; JPverb.ar(in, t60:1, damp:0, size:1)}).set(\wet12, 0.3)

/////////////////////////////////
// play
~p[\bass].play(fadeTime:8, out:0);
~p[\bass].stop(fadeTime:8);
~p[\bass].vol = 2

App.recordWorkspace("ws13");
s.stopRecording;