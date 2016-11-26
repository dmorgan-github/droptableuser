(
ProxySynthDef(\s1, {

	var trig = \trig.tr;

	var switch = 1 - trig;

	var freq = Vibrato.ar( K2A.ar(\freq.kr(300)), 0.1, 0.001 ).lag(0.12 * switch);

	var sig = SinOscFB.ar(freq, 0.45) + SinOsc.ar(freq * [1, 2.05]);

	var env = {
		var rel = \rel.kr(1);
		var atk = \atk.kr(0.01);
		var curve = \curve.kr(-4);
		var dur = \dur.kr(1);
		EnvGen.kr(Env([0,0,1,0], [0, atk, rel], [curve]), trig, timeScale: dur)
	};

	Splay.ar(sig) * env * \amp.kr(0.1) * AmpCompA.kr(freq);

}).add;
)

///////////////////////////////////////////
~s1 = App.monoDevice(\s1);
(~s1.pattern.set(
	\delta, Pseq([1, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5], inf) * 0.25,
	\trig, Pseq([1, 1, 0, 1, 1, 0, 1], inf),
	\atk, Pwhite(0.01, 0.05, inf),
	\scale, Scale.locrian,
	\freq, Pseq(['e3', 'e3', 'd3', 'e3', 'g3', 'a3', 'g3'].namecps, inf)
));
(~s1.node[10] = \filter -> {arg in;
	GVerb.ar(in, 200, taillevel: 0.5);
})
~s1.player.stop;
~s1.player.play;