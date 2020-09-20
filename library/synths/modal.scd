(
SynthDef(\modal, {
	var vel = \vel.kr(1);
	var detune = \detuneratio.kr(1);
	var freq = \freq.kr(440) * ([1, detune] ** Rand(-1, 1));
	var harm = \harm.kr(0);
	var k = (1..8);
	var ratio = k * (1 + ((k-1) * harm));
	var bright = \bright.kr(0.5).linlin(0, 1, 80, 8000);
	//var noise = \noise.kr(0.5).linlin(0, 1, 0.001, 1);
	//var exciter = LPF.ar(WhiteNoise.ar, bright) * Decay2.ar(Impulse.ar(0), 0, noise) * noise.sqrt.reciprocal;
	//var exciter = LPF.ar(PinkNoise.ar, bright) * Decay2.ar(Impulse.ar(0), 0, noise) * noise.sqrt.reciprocal;
	var exciter = LPF.ar(Impulse.ar(0), bright);
	var sig = DynKlank.ar(`[
		ratio,
		(k * -3).dbamp,
		ratio.squared.reciprocal * 5
	], exciter, freq);

	var aeg = Env.asr(
		\atk.kr(0),
		\suslevel.kr(1),
		\rel.kr(1),
		curve:\curve.kr(-4)
	).ar(doneAction:Done.freeSelf, gate:\gate.kr(1));

	sig = sig * 10.dbamp;


	sig = sig * aeg * \amp.kr(0.1) * AmpCompA.kr(freq) * vel;
	Out.ar(\out.kr(0), sig);
}, metadata: (
	specs: (
		\harm: ControlSpec(-0.06, 2, \lin, 0, 0),
		\bright: ControlSpec(0, 1, \exp, 0, 0.5)
	)
)).add;
)