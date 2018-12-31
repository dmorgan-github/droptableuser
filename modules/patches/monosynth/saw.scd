~p.push;

/////////////////////////////////////////
// t3 settings

Pdefn(\t3_mtranspose, 0);
Pdefn(\t3_root, 0);
Pdefn(\t3_scale, Scale.dorian);
Pdefn(\t3_dur, 0.25);
Pdefn(\t3_degrees, Pseq([0], inf));

/////////////////////////////////////////
// t3 base pattern
(
Pdef(\t3_base,

	Pbind(
		\type, \set,
		\id, Pfunc({arg evt; evt[\node].nodeID;}),
		\args, #[\trig, \freq, \amp],// ++ params.keys.asArray,
		\trig, 1,
		\degrees, Pdefn(\t3_degrees),
		\foo, Pif(Pfunc({arg evt; evt[\seq].coin}), 1, Rest()),
		\degree, Pkey(\degrees) + Pkey(\offset),
		\scale, Pdefn(\t3_scale),
		\mtranspose, Pdefn(\t3_mtranspose),
		\root, Pdefn(\t3_root),
		\dur, Pdefn(\t3_dur),
		\amp, Pkey(\amp) * 0.2
	)
);
)

/////////////////////////////////////////
// t3
(
var envir = currentEnvironment;

var patterns = [
	{
		var offset = Pseq([0,1], inf).asStream;
		var seq = Array.fill(32, 0)[1] = 1;
		var p = Pbind(
			\amp, 0.dbamp,
			\octave, 5,
			\seq, Pseq(seq, inf),
			\offset, Pfunc({arg evt;
				if (evt[\seq] > 0) {
					offset.next;
				}{
					0
				}
			}),
		);

		var n = {

			var numvoices = 2;
			var detune = \detune.kr(0.01);
			var trig = \trig.tr;
			var freq = Vibrato.kr(
				\freq.kr(432).lag(\lag.kr(0.05)),
				\vrate.kr(6),
				\vdepth.kr(0.001)
			);

			var env = Env.linen(attackTime:2, sustainTime:4, releaseTime:4).kr(gate:trig);

			var sig = {
				Saw.ar(freq * LFNoise2.kr(\ddepth.kr(5)).range(1 + detune.neg, 1 + detune));
			}.dup(numvoices) * Array.fill(numvoices,1).normalizeSum;

			//sig = RLPF.ar(sig, 880, 0.2);

			sig = RLPF.ar(sig, SinOsc.kr(1/8).range(880, 1220), 0.3);

			sig = Pan2.ar(sig.sum, \pan.kr(0)) * env * \amp.kr(-3.dbamp);
			sig;
		};

		(k:\t3_1, p:p, n:n);
	},

	{
		var offset = Pseq([3,4,5], inf).asStream;
		var seq = Array.fill(48, 0)[1] = 1;
		var p = Pbind(
			\amp, 0.dbamp,
			\octave, 6,
			\seq, Pseq(seq, inf),
			\offset, Pfunc({arg evt;
				if (evt[\seq] > 0) {
					offset.next;
				}{
					0
				}
			}),
		);

		var n = {

			var numvoices = 2;
			var detune = \detune.kr(0.01);
			var trig = \trig.tr;
			var freq = Vibrato.kr(
				\freq.kr(432).lag(\lag.kr(0.05)),
				\vrate.kr(6),
				\vdepth.kr(0.001)
			);

			var env = Env.linen(attackTime:2, sustainTime:4, releaseTime:4).kr(gate:trig);

			var sig = {
				Saw.ar(freq * LFNoise2.kr(\ddepth.kr(5)).range(1 + detune.neg, 1 + detune));
			}.dup(numvoices) * Array.fill(numvoices,1).normalizeSum;

			//sig = RLPF.ar(sig, 1220, 0.2);

			sig = RLPF.ar(sig, SinOsc.kr(1/12).range(880, 1220), 0.3);

			sig = Pan2.ar(sig.sum, \pan.kr(0)) * env * \amp.kr(-3.dbamp);
			sig;
		};

		(k:\t3_2, p:p, n:n);
	},

	{
		var offset = Pseq([-2,0], inf).asStream;
		var seq = Array.fill(52, 0)[1] = 1;
		var p = Pbind(
			\amp, 0.dbamp,
			\octave, 4,
			\seq, Pseq(seq, inf),
			\offset, Pfunc({arg evt;
				if (evt[\seq] > 0) {
					offset.next;
				}{
					0
				}
			}),
		);

		var n = {

			var numvoices = 2;
			var detune = \detune.kr(0.01);
			var trig = \trig.tr;
			var freq = Vibrato.kr(
				\freq.kr(432).lag(\lag.kr(0.05)),
				\vrate.kr(6),
				\vdepth.kr(0.001)
			);

			var env = Env.linen(attackTime:2, sustainTime:8, releaseTime:4).kr(gate:trig);

			var sig = {
				Saw.ar(freq * LFNoise2.kr(\ddepth.kr(5)).range(1 + detune.neg, 1 + detune));
			}.dup(numvoices) * Array.fill(numvoices,1).normalizeSum;

			sig = RLPF.ar(sig, SinOsc.kr(1/16).range(110, 770), 0.3);

			sig = Pan2.ar(sig.sum, \pan.kr(0)) * env * \amp.kr(-3.dbamp);
			sig;
		};

		(k:\t3_3, p:p, n:n);
	}

].collect({arg func, i;
	var obj = func.();
	var key = obj[\k];
	var pat = obj[\p];
	var node = obj[\n];
	if (node.isKindOf(Function)) {
		envir[key] = node;
		node = envir[key];
	};
	Pdef(\t3_base) <> Pbind(\node, Pfunc({node})) <> pat;
});

Pdef(\t3_main, {
	"init".debug(\t3_main);
	Ppar(patterns, inf);
});
)

/////////////////////////////////////////
// t3 play

~t3_1.play;
~t3_1.stop;
Pdef(\t3_main).play;
Pdef(\t3_main).stop;

~t3_2.play;
~t3_2.stop;


~t3_mix[0] = \mix -> {~t3_1.ar};
~t3_mix[1] = \mix -> {~t3_2.ar};
~t3_mix[2] = \mix -> {~t3_3.ar};
~t3_mix.play;
~t3_mix.stop;


(
~t3_reverb = {
	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in, 10, 0, 5);
	fx
}
)
~t3_reverb.play;
~t3_reverb <<> ~t3_mix
