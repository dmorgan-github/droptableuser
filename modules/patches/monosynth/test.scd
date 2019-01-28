
(
Ppar([
	Pdef(\s4_v1),
	Pdef(\p2_s1_v1)
]).play
)



(
var key = \bd;
Ndef(key, {
	/*
	var trig = \trig.tr;
	var freq = Env([444,444,33],[0, 0.1], -7).kr(gate:trig);
	var sig = SinOsc.ar(freq, 0.5pi).tanh
	+ (WhiteNoise.ar(0.1) * Decay2.kr(trig, attackTime:0.0001, decayTime:0.01))
	+ SinOsc.ar(61);
	var env = Env.perc(attackTime: 0.001, releaseTime: 0.2, curve: -4 ).kr(gate:trig);
	sig = sig * env * \amp.kr(0.1);
	Pan2.ar(sig, \pan.kr(0));
	*/

	// by Nathan Ho
	// TODO: parameterize
	var trig, snd;
    //trig = Impulse.ar(2);
	trig = \trig.tr;
    snd = Trig.ar(trig, 5e-3) * 3;
    snd = snd - OnePole.ar(snd, 1 - 100e-3) + (snd * 0.04);
    snd = Select.ar(snd > 0, [0.7 * snd / (1 - snd), snd]);
    snd = Ringz.ar(snd, 60 * (1 + (OnePole.ar(Trig.ar(trig, 10e-3), 0.96)) + (snd * 0.1)), 1);
    snd = snd * -40.dbamp;
	snd ! 2 * \amp.kr(0.dbamp);
});

Pdef(key,
	Pdef(\nbind) <> (node:Ndef(key))
	<> Pbind(*Ndef(key)
		.controlNames
		.reject({arg ctrl; (ctrl.name == \freq) || (ctrl.name == \trig)})
		.collect({arg ctrl; [ctrl.name, ctrl.defaultValue]}).flatten)
);
)

Pdef(\bd).play;
Pdef(\bd).stop;

(
Pdef(\bd_v1,
	Pchain(
		Pbind(\dur, 0.5, \foo, 1),
		Pdef(\bd)
	)
)
)


Pdef(\bd_v1).play;
Pdef(\bd_v1).stop;



(
Pdef(\test,
	Ppar([
		Pdef(\s4_v1),
		Pdef(\p2_s1_v1)
	])
)
)


(
Pdef(\test,
	Pdef(\t1_filter)
	<> Ppar([

		Pbind(\dur, Prand([0.5, 0.25, 1], inf), \bobo, Rest()) <> Pdef(\bd_v1),

		Pbind(\degree, Pif(Pfunc({arg evt; (0.5).coin}), Pkey(\degree), Pn(0,inf) ))
		<> Ppar([
			Pdef(\s4_v1),
			Pdef(\p2_s1_v1)
		], inf)

	], inf)
)
)

(
Pdef(\test,
	Ppar([
		Pdef(\bd_v1),
		Pdef(\s4_v1),
		Pdef(\p2_s1_v1)
	], inf)
)
)

(
Pdef(\test,

	Ppar([

		Pdef(\bd_v1),

		Pbind(\degree, Pif(Pfunc({arg evt; (0.7).coin}), Pkey(\degree), Pn(2,inf) ), \scale, Scale.chromatic)
		<> Ppar([
			Pdef(\s4_v1),
			Pdef(\p2_s1_v1)
		], inf)
	], inf)
)
)

Pdef(\p3_s7_v1)

Pdef(\test).play;
Pdef(\test).stop;


Pdef(\bd_v1).play;

(
//s.record;
Pspawner({arg ps;

	var test2, test3, test4;
	var test = ps.par( Pdef(\test) );

	ps.wait(32);

	test.stop;

	test2 = ps.par( Pdef(\p2_s1_v1) );

	test3 = ps.par( Pdef(\p3_s7_v1) );

	ps.wait(16);

	test2.stop;

	test = ps.par( Pdef(\test) );
	test4 = ps.par( Pdef(\p3_s6_v1) );

	test2.stop;

	ps.wait(64);

	test2.stop;
	test3.stop;
	test.stop;
	test4.stop;

}).play;
)



App.saveWorkspace("ws7", rec:true);
s.stopRecording

