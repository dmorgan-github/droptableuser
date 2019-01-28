(
Fdef(\bd, {arg key;

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
		snd = snd ! 2 * \amp.kr(0.dbamp);

		snd = snd.blend(JPverb.ar(snd, \rev_t60.kr(1), 0, \rev_size.kr(1)), \rev_wet.kr(0) );

		snd;
	});

	Pdef(key,
		Pdef(\nbind) <> (node:Ndef(key))
		<> Pbind(*Ndef(key)
			.controlNames
			.reject({arg ctrl; (ctrl.name == \freq) || (ctrl.name == \trig)})
			.collect({arg ctrl; [ctrl.name, ctrl.defaultValue]}).flatten)
	)
});
)

//Fdef(\bd).(\bd_s1);
//Pdef(\bd_s1).play;
//Pdef(\bd_s1).stop;