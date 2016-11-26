(
ProxySynthDef(\s5, {

	var trig = \trig.tr;
	var pan = \pan.kr(0);

	var sig = StandardL.ar;
	var env = {
		var rel = \rel.kr(1);
		var atk = \atk.kr(0.01);
		var curve = \curve.kr(-4);
		EnvGen.kr(Env([0,0,1,0], [0, atk, rel], [curve]), trig, timeScale: \dur.kr(1))
	};

	Pan2.ar(sig, pan) * env * \amp.kr(0.1);

}).add;
)

///////////////////////////////////////////
~s5 = App.monoDevice(\s5);
(~s5.pattern.set(
	\delta, 0.125,
	\dur, Pkey(\delta),
	\amp, 0.02
))
(~s5.node[10] = \filter -> {arg in;
	GVerb.ar(in, 200, taillevel: 0.5);
})
~s5.player.play;
~s5.player.stop;