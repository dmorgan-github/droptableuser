(
SynthDef(\modal, {
	var vel = \vel.kr(1);
	var detune = \detuneratio.kr(1);
	var freq = \freq.kr(440) * ([1, detune] ** Rand(-1, 1));
	var harm = \harm.kr(0);
	var k = (1..8);
	var ratio = {
		var val = k * (1 + ((k-1) * harm));
		val/val[0];
	}.();

	var bright = \bright.kr(0.5).linlin(0, 1, 80, 8000);
	var exciter = LPF.ar(Impulse.ar(0), bright);
	var morph = \morph.kr(0.0).linlin(0, 1, 1, 100);

	var sig = DynKlank.ar(`[
		ratio,
		(k * -3).dbamp,
		ratio.squared.reciprocal * 5;
	], exciter, freq, decayscale: morph);

	var aeg = Env.perc(
		attackTime:0.01,
		releaseTime:\rel.kr(1),
		curve:\curve.kr(-4)
	).ar(doneAction:Done.freeSelf, gate:1);

	sig = sig * 0.dbamp;

	// sub
	sig = sig + (SinOsc.ar(freq * \sinratio.kr(0.5)) * \sine.kr(0.2));

	sig = sig * aeg * \amp.kr(0.1) * AmpCompA.kr(freq) * vel;

	sig = Splay.ar(sig, \spread.kr(1), center:\pan.kr(0));

	sig = Limiter.ar(sig);

	Out.ar(\out.kr(0), sig);

}, metadata: (
	credit: "adapted from formulas by Nathan Ho",
	type: \perc,
	created: "09/27/2020",
	specs: (
		\harm: ControlSpec(-0.06, 2, \lin, 0, 0),
		\bright: ControlSpec(0.0, 1.0, \lin, 0, 0.5)
	)
)).add;
)