
(~p[\bass][0] = {

	var trig = \trig.tr;

	var freq = Vibrato.kr(\freq.kr(65.45), 6, 0.005);

	var sig = [
		{
			var width = LFNoise1.kr(1/8).range(0.3, 0.7);
			var sig = { Pulse.ar(freq * LFNoise2.kr(1/32).range(0.99, 1.01), width:width) }!2;
			sig = RLPF.ar(sig, 440, 0.5);
			sig.tanh;
		},
		{
			var sig = SyncSaw.ar(freq * -12.1.midiratio, freq * LFNoise2.kr(1/16).range(0.99, 1.01));
			sig = RLPF.ar(sig, 880, 0.8);
			(sig * 1.5).tanh;
		}
	].collect(_.value).flatten * [1,0.8].normalizeSum;

	var env = Env.linen(sustainTime:8, releaseTime:8, curve:-2).kr(gate:trig);
	sig = Splay.ar(sig.sum) * env * AmpCompA.kr(freq) * \amp.kr(-12.dbamp);
	sig = JPverb.ar(sig, 10, 0, 5, modDepth:0.5) * 0.7 + sig;

	sig;
})

~p[\bass].play;

(~p[\bass][2] = nil\set -> Pbind(
	\trig, 1,
	\degree, 0,
	\octave, 3,
	\dur, 16,
	\amp, -15.dbamp
))



(
var node = ~p[\bass].quant_(0);
Pdef(\bass, {arg out = 0;
	node.play(fadeTime:0, out:out);
	Pbind(\type, \set,
		\id, Pfunc({node.nodeID}),
		\args, #[\trig, \amp, \freq],
		\trig, 1,
		\degree, 0,
		\octave, 3,
		\dur, 16,
		\amp, -18.dbamp
	)
}).quant_(0)
)

Pdef(\bass).play;