(
ProxySynthDef(\gbman1, {

	var amp = \amp.kr(0.1);
	var trig = \trig.tr;
	var freq = (\freq.kr * [1, 1.01]).lag(\lag.kr(0.05) );
	var dur = \dur.kr(1);

	var env = EnvGen.kr(Env([0,0,1,0],
		[1e-6, \atk.kr(0.01), \rel.kr(1) - \atk.kr],
		curve: [\curve1.kr(-4), \curve2.kr(-4)]
	), gate: trig, timeScale: dur );

	var sig = GbmanL.ar(freq, 0.5, 0.05);
	//sig = RLPF.ar(sig, fenv, qenv );
	sig * env * amp;

}).add;
)

~gbman1 = App.monoDevice(\gbman1);
(~gbman1.pattern.set(
	\delta, Pseq([
		Pbjorklund2(Pseq([3,5], inf), 8, 2) * 0.125,
		Pbjorklund2(Pseq([3,4], inf), 7, 2) * 0.25,
		Pseq([2, [1,[2,[1,2,1]],1]].convertRhythm, 2) * 0.5

	], inf), //Pseq( [0.125], inf),
	\dur, Pkey(\delta) * 0.5,
	\freq, Pseq( ('B5'.namemidi + Scale.ritusen.degrees.scramble).midicps, inf),
	\amp, 0.1
))

(~gbman1.node[10] = \filter -> {arg in;
	var fx1 = FbC({arg fb; in + fb.reverse * 0.4}, 0.25);
	var fx2 = FbC({arg fb; in + fb.reverse * 0.4}, 0.375);
	in + XFade2.ar(fx1, fx2, LFTri.kr(0.5).range(-1, 1) );
});
~gbman1.player.stop;
~gbman1.player.play;
