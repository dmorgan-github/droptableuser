(
ProxySynthDef(\resonant_pad, {

	var trig = \trig.tr;
	var env = Env.perc().kr(gate: trig, timeScale: \dur.kr(1));

	var sig1 = {

		var exc = PinkNoise.ar(0.4) * Env.perc(0.5).kr(gate: trig, timeScale: \dur.kr(1) * 1.5);
		var tension = LFNoise0.kr(0.1).range(0.01, 0.1);
		var loss = LFNoise0.kr(0.1).range(0.999999, 0.999);
		var sig = MembraneHexagon.ar(exc, tension, loss);
		sig;

	}.value;

	var sig2 = {
		var env = Env.perc(1, 0.5).kr(gate: trig, timeScale: \dur.kr(1));
		var fb = Env([0.2, 0.2, 0.7], [0, 1], [-4]).kr(gate: trig, timeScale: \dur.kr(1));
		var freq = Vibrato.ar(K2A.ar( \freq.kr(300).lag(0.12) ), 5, 0.01 );
		var sig = SinOscFB.ar( freq * [1, 1.01], fb, mul:1);
		sig * env;

	}.value;

	var sig = sig1 + sig2;
	Splay.ar(sig) * \amp.kr(0.1);

}).add;
)

~pad1 = Dloopr2(1);
(~pad1.node[1] = \filter -> {arg in;

	var sig = in;
	sig = GVerb.ar(sig, 300, taillevel: 9);
	sig = JPverb.ar(sig);
	sig;
});

(
~pad1.grid = (0..5).collect({
	(0..15).collect({arg item;
		if (0.1.coin) { [4, 5].choose } {0}
	})
})
);


(
~pad1.func = {arg x, y, val, time;
	var octave = val;
	(instrument: \resonant_pad,
		\trig: 1,
		\amp: 0.05,
		\degree: y,
		\octave: val,
		\mtranspose: 0,
		\dur: time * 2,
		\scale: Scale.major
	);
};
)

~pad1.dur = 2;

~reaper.record;
~pad1.player.play(quant:1.0);

~pad1.player.stop;