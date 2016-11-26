(
ProxySynthDef(\pad2, {

	var amp = \amp.kr(0.1);
	var trig = \trig.tr;
	var freq = (\freq.kr * [1, 1.01]).lag(\lag.kr(0.012) );
	var dur = \dur.kr(1);

	var env = {
		Env(
			[0, 0, 1, 0],
			[0, \atk.kr(0.01), \rel.kr(1)],
			[\curve.kr(-4.0)]
		).kr(gate: trig, timeScale: dur);
	};

	var fenv = App.envControl(\f, [2,6,2], [1,1], [-4, 4], gate: trig, timeScale: dur, levelScale: freq);
	var qenv = App.envControl(\q, [0.2, 0.3, 0.2], [1,1], [-4, 4], gate: trig, timeScale: dur, levelScale: 2);

	var sig = Pulse.ar( Vibrato.ar( K2A.ar(freq), 6, 0.01 ), SinOsc.kr(5).range(0.2, 0.7));

	var sig2 = {
		var sig = WhiteNoise.ar(0.3);
		var env = Env([0,0,1,0],[0,0.9,0.1],[-4]).kr(gate: trig, timeScale: dur);
		sig * env;
	};

	sig = RLPF.ar(sig + sig2, fenv, qenv);
	//sig = CompanderD.ar(sig);//, slopeBelow: MouseX.kr(1, 2).poll, slopeAbove: MouseY.kr(1,2).poll );
	Splay.ar(sig) * env * amp

}).add;
)

~pad2 = App.monoDevice(\pad2);
(~pad2.pattern.set(
	\delta, 2,
	\dur, Pkey(\delta),
	\freq, Pseq( ('B2'.namemidi + Scale.ritusen.degrees.scramble).midicps, inf),
	\amp, 0.03
));
(~pad2.node[10] = \filter -> {arg in;
	in = FbC({arg fb; in + fb.reverse * 0.8}, 0.375);
	in = JPverb.ar(in);
	GVerb.ar(in, 300, taillevel: 2);
});
~pad2.player.stop;
~pad2.player.play;


~pad2.node.set(\wet10, 1)