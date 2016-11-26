(

ProxySynthDef(\gbman, {

	var trig = \trig.tr;
	var freq = \freq.kr(440) + [0, \dtune.kr(0)];
	var fenv = App.envControl(\f, [0.7, 1.5, 0.7], [1, 1], [-4, -4], Impulse.kr(0.5) );
	var qenv = App.envControl(\q, [0.3, 0.3, 0.3], [1, 1], [-4, -4], Impulse.kr(0.5) );

	var env = EnvGen.kr(Env([0,0,1,0],
		[1e-6, \atk.kr(0.01), \rel.kr(1)],
		curve: [\curve.kr(-4)]
	), gate: trig, levelScale: \amp.kr(0.1), timeScale: \dur.kr(1) );

	var sig = GbmanL.ar(freq, [1.2, 0.1], [1.99, 1.1] );
	sig = MoogFF.ar(sig.tanh * 5, freq * fenv + LFNoise1.kr([0.5, 0.1]), LFNoise2.kr(0.5).range(2, 4) - qenv);
	sig * env;

}).add;



)