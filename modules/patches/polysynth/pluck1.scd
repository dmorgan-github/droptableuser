(
ProxySynthDef(\pluck1, {

	var trig = \trig.tr;
	var freq = \freq.kr(300);

	var sig = {

		var c3 = 20;
		var fB = 2;
		var release = 1;
		var env = Env.new([0,1, 1, 0],[0.001,0.006, 0.0005],[5,-5, -8]);
		var inp = LFClipNoise.ar(2000) * EnvGen.ar(env, gate: trig);
		DWGPluckedStiff.ar(freq, pos:0.1, c3:c3, inp:inp, release:release, fB:fB);
	};

	var env = {
		Env(
			[0, 0, 1, 0],
			[0, \atk.kr(0.01), \rel.kr(1)],
			[\curve.kr(-4.0)]
		).kr(gate: trig, timeScale: \dur.kr(1));
	};

	Splay.ar(sig) * env * \amp.kr(0.1) * AmpCompA.kr(freq);

}).add;
)

///////////////////////////////////////////

~p[\pluck] = Pmono(\pluck1, \degree, Pwhite(0, 4, inf), \delta, 0.125, \octave, 6);
~p[\pluck].play
~p[\pluck].stop;

(~p[\plug_verb] = {
	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in);
	fx
})

~p[\plug_verb] <<> ~p[\pluck];
~p[\plug_verb].play
~p[\plug_verb].stop;

