(
ProxySynthDef(\formlet1, {

	var trig = \trig.tr;
	var pan = \pan.kr(0);
	var freq = \freq.kr(300);

	var sig = {
		Formlet.ar(Impulse.ar(20, 0.5), freq/*SinOsc.kr(0.5).range(1000, 3000)*/, 0.01, 0.1)
	};

	var env = {
		Env(
			[0, 0, 1, 0],
			[0, \atk.kr(0.01), \rel.kr(1)],
			[\curve.kr(-4.0)]
		).kr(gate: trig, timeScale: \dur.kr(1));
	};

	Pan2.ar(sig, pan) * env * \amp.kr(0.1);

}).add;
)

///////////////////////////////////////////
~formlet1 = App.monoDevice(\formlet1);
(~formlet1.pattern.set(\degree, Pwhite(0, 6, inf), \pan, Pwhite(-1, 1, inf), \octave, 9, \delta, 0.125 ))
(~formlet1.node[10] = \filter -> {arg in; GVerb.ar(in, 300);})
~formlet1.player.play;
~formlet1.player.stop;