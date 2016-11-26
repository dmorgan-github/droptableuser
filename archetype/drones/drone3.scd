(
currentEnvironment.free;
p=ProxySpace.push(s);
p.makeTempoClock;
ProxySynthDef.sampleAccurate = true;
)
p.clock.tempo = 60/60;
p.gui;


~noise1.clear;
~noise1.stop(fadeTime:10);
~noise1.play(fadeTime: 2, numChannels: 2).quant_(2);
(~noise1[0] = {

	var trig = \trig.tr;
	var freq = (\freq.kr * [1, 1.01]).lag(\lag.kr(0.12) );
	var dur = \dur.kr(1);

	var env = EnvGen.kr(Env([0,0,1,0],
		[1e-6, \atk.kr(0.01), \rel.kr(1) - \atk.kr],
		curve: [\curve1.kr(-4), \curve2.kr(-4)]
	), gate: trig, timeScale: dur );

	var fenv = {
		var ftime1 = \ftime1.kr(1);
		var ftime2 = \ftime2.kr(1);
		var fcurve1 = \fcurve1.kr(-4);
		var fcurve2 = \fcurve2.kr(-4);
		var ftimeScale = dur;
		var flevelScale = freq;
		var fgate = trig;
		var fenv = EnvGen.kr(Env([2,2,4,2],
			[1e-6, ftime1, ftime2],
			curve: [fcurve1, fcurve2]
		), gate: fgate, levelScale: flevelScale, timeScale: ftimeScale );
		fenv;
	}.value;

	var qenv = {
		var qtime1 = \qtime1.kr(1);
		var qtime2 = \qtime2.kr(1);
		var qcurve1 = \qcurve1.kr(-4);
		var qcurve2 = \qcurve2.kr(4);
		var qtimeScale = dur;
		var qlevelScale = 1 * 2;
		var qgate = trig;
		var qenv = EnvGen.kr(Env([0.5,0.5,0.01,0.5],
			[1e-6, qtime1, qtime2],
			curve: [qcurve1, qcurve2]
		), gate: qgate, levelScale: qlevelScale, timeScale: qtimeScale );
		qenv;

	}.value;

	var sig = HenonC.ar(freq, LFCub.kr(1).range(0.01, 0.2), LFTri.kr(1).range(0.8, 1.0), 1, 1);
	sig = SVF.ar(sig, fenv, LFGauss.kr([2, 0.1]).range(0.5, 0.9) );
	sig * env * 0.5;
});

(~noise1[10] = \set -> Pbind(
	\delta, Pbjorklund2(Pseq([3,5], inf), 8, inf) * 0.125, //Pseq( [0.125], inf),
	\args, [\trig, \dur, \freq],
	\trig, 1,
	\dur, Pkey(\delta),
	\freq, Pseq( ('B1'.namemidi + Scale.ritusen.degrees).midicps, inf)
	)
);

~noise1[20] = nil
(~noise1[20] = \filter -> {arg in;
	var fx1 = FbC({arg fb; in + fb.reverse * 0.4}, 0.25);
	var fx2 = FbC({arg fb; in + fb.reverse * 0.4}, 0.375);
	in + XFade2.ar(fx1, fx2, LFTri.kr(0.5).range(-1, 1) );
})
