(
ProxySynthDef(\metal1, {

	var trig = \trig.tr;
	var pan = \pan.kr(0);

	var sig = {
		var noise = PinkNoise.ar;
		Klank.ar(`[[800, 1071, 1153, 1723], nil, [1, 1, 1, 1]], noise);
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
~metal1 = App.monoDevice(\metal1);
(~metal1.pattern.set(\delta, 0.125, \dur, Pkey(\delta), \amp, 0.01))
(~metal1.node[10] = \filter -> {arg in; GVerb.ar(in, 300, taillevel: 1);})
~metal1.player.play;
~metal1.player.stop;