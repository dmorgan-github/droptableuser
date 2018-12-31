(
~p[\faraway][0] = {

	var trig = \trig.tr;
	var freq = Vibrato.kr(\freq.kr(432).lag(0.2), 6, 0.01);

	var sig = [
		{
			var sig = VarSaw.ar(freq * LFNoise2.kr(1/16).range(0.99, 1.01));
			sig = RLPF.ar(sig, 2200, 0.6).tanh;
			sig;// * 1.5;
		}
	].collect(_.value) * [1].normalizeSum;

	var env = Env(
		[0,1,0.7,0.7,0],
		[\atk.kr(0.001), \decay.kr(0.1), \sus.kr(1), \rel.kr(1)],
		curve:\curve.kr(-4)
	).kr(gate:trig);

	sig = Splay.ar(sig) * env * AmpCompA.kr(freq) * \amp.kr(-12.dbamp);

	//sig = BPF.ar(sig, 3300, 0.8);// * + sig;

	sig = JPverb.ar(sig, 15, 0, 5) * 0.8 + sig;

	sig = sig * Env.circle([0,1,1,0], [2,8,8,6], -4).kr();

	sig;
}
)

(~p[\faraway][2] = nil\set -> Pbind(
	\trig, 1,
	\scale, Scale.chromatic,
	\root, 0,
	\degree, Pwrand([0, 2, 3, 7, 10, -16, -4], [1,1,1,1,1,0.5,0.5].normalizeSum, inf).trace,
	\octave, 6,
	\dur, Prand([0.5, 0.25, 1, 2], inf)
))

~p[\faraway].play(fadeTime:10);
~p[\faraway].stop(fadeTime:10);


Pdef(\faraway).clear;
(
var node = ~p[\faraway];
Pdef(\faraway, {arg out = 0;
	node.play(fadeTime:0, out:out);
	Pbind(\type, \set,
		\id, Pfunc({node.nodeID}),
		\args, #[\trig, \amp, \freq],
		\trig, 1,
		\scale, Scale.chromatic,
		\root, 0,
		\degree, Pwrand([0, 2, 3, 7, 10, -16, -4], [1,1,1,1,1,0.5,0.5].normalizeSum, inf),
		\octave, 6,
		\dur, Prand([0.5, 0.25, 1, 2], inf)
	)
})
)

Pdef(\faraway).play;