(
ProxySynthDef(\bass2, {

	var trig = \trig.tr;

	var freq = \freq.kr(300);

	var fenv = {
		Env([0.7, 0.7, 1.5, 0.7], [0, 1, 1], [-4, -4]).kr(gate: trig);
	};

	var qenv = {
		Env([0.3, 0.3, 0.3, 0.3], [0, 1, 1], [-4, -4]).kr(gate: trig);
	};

	var env = {
		Env(
			[0, 0, 1, 0],
			[0, \atk.kr(0.01), \rel.kr(1)],
			[\curve.kr(-4.0)]).kr(gate: trig, timeScale: \dur.kr(1));
	};

	var sig = GbmanL.ar(freq, [1.2, 0.1], [1.99, 1.1] );

	sig = MoogFF.ar(sig.tanh * 5,
		freq.linlin(65, 3000, 880, 1600) * fenv + LFNoise1.kr([0.5, 0.1]),
		LFNoise2.kr(0.5).range(2, 4) - qenv);

	Splay.ar(sig) * env * \amp.kr(0.1) * AmpCompA.kr(freq);

}).add;
)


///////////////////////////////////////////
~bass2 = App.monoDevice(\bass2);
(~bass2.pattern.set(\amp, 1))
~bass2.player.play;
~bass2.player.stop;