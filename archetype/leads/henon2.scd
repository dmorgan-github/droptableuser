(
ProxySynthDef(\henon2, {

	var amp = \amp.kr(0.1);
	var trig = \trig.tr;
	var lag = \lag.kr(0.0);
	var freq = (\freq.kr.lag(lag) * [1, 1.01]);
	var dur = \dur.kr(1);

	var env = EnvGen.kr(Env([0,0,1,0],
		[1e-6, \atk.kr(0.01), \rel.kr(1)],
		curve: [0, \curve2.kr(-4)]
	), gate: trig, timeScale: dur );

	var sig = HenonC.ar(freq, 0.4, 0.9, 1, 1);
	sig * env * amp

}).add;
)

~henon2 = App.monoDevice(\henon2);
(~henon2.pattern.set(
	\delta, Pbjorklund2(Pseq([3,5], inf), 7, inf) * 0.125,
	\dur, Pkey(\delta) * 1,
	\freq, Pseq( ('B4'.namemidi + Scale.ritusen.degrees.scramble).midicps, inf) * Prand([0.5, 1], inf),
	\lag, 0.12,
	\amp, 0.5
));
(~henon2.node[10] = \filter -> {arg in;
	var fx1 = FbC({arg fb; in + fb.reverse * 0.4}, 0.25);
	var fx2 = FbC({arg fb; in + fb.reverse * 0.4}, 0.375);
	in + XFade2.ar(fx1, fx2, LFTri.kr(0.5).range(-1, 1) );
})
~henon2.player.stop;
~henon2.player.play;