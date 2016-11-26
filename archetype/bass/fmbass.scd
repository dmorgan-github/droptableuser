(
ProxySynthDef(\fmbass, {

	var amp = \amp.kr(0.1);
	var trig = \trig.tr;
	var freq = (\freq.kr * [1, 1.01]);
	var dur = \dur.kr(1);

	var env = EnvGen.kr(Env([0,0,1,0],
		[1e-6, \atk.kr(0.01), \rel.kr(1) - \atk.kr],
		curve: [\curve1.kr(-4), \curve2.kr(-4)]
	), gate: trig, timeScale: dur );

	var fenv = App.envControl(\f, [2,4,2], [1,1], [-4, 4], gate: trig, timeScale: dur, levelScale: freq);
	var qenv = App.envControl(\q, [0.2, 0.05, 0.2], [1,1], [4, 4], gate: trig, timeScale: dur, levelScale: 2);

	//var sig = LatoocarfianC.ar(freq, a: -2.5, b: 2.5, c: 0.556, d: 1.1123, xi: 1, yi: 0.01);

	var index = Env([6,6,1],[0,1],[-4]).kr(gate: trig, timeScale: dur);
	var sig = PMOsc.ar(Vibrato.ar( K2A.ar(freq) ), freq * 0.5, index).tanh;

	//sig = DFM1.ar(sig, fenv, qenv);
	sig = BLowPass.ar(sig, 880);
	//sig = SVF.ar(sig, fenv, qenv);
	sig * env * amp;

}).add;
)

~fmbass = App.monoDevice(\fmbass);
(~fmbass.pattern.set(
	\delta, Pseq([

		Pbjorklund2(Pseq([3,5], inf), 8, 2) * 0.125,
		Pbjorklund2(Pseq([3,4], inf), 7, 2) * 0.25

	], inf),
	\dur, Pkey(\delta),
	\freq, Pseq( ('B1'.namemidi + Scale.ritusen.degrees.scramble).midicps, inf),
	\amp, 0.07
));
(~fmbass.node[10] = \filter -> {arg in;
	var fx1 = FbC({arg fb; in + fb.reverse * 0.4}, 0.25);
	var fx2 = FbC({arg fb; in + fb.reverse * 0.4}, 0.375);
	in + XFade2.ar(fx1, fx2, LFTri.kr(0.5).range(-1, 1) );
});
~fmbass.player.stop;
~fmbass.player.play;