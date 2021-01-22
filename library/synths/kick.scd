(
SynthDef(\kick, {

	var freq = \freq.kr(48.99);

	var freqmul = Env.perc(0,
		releaseTime:\pdecay.kr(0.135),
		curve:\pcurve.kr(-4)
	).ar(gate:1).linlin(0, 1, 1, \freqmul.kr(3.99).max(1));

	var sig = SinOsc.ar(freq * freqmul, \phaseoffset.kr(0.1));

	var aeg = Env.perc(0.001,
		releaseTime:\rel.kr(0.34),
		curve:\curve.kr(0)
	).ar(doneAction:Done.freeSelf) * Line.ar(2, 1, 0.002);

	sig = tanh(sig * \drive.kr(1.02));

	sig = LeakDC.ar(sig);

	sig = CompanderD.ar(sig, \thresh.kr(0.1), \slopebelow.kr(0.5), \slopeabove.kr(1.3), 0.001);

	sig = sig * aeg * \amp.kr(-3.dbamp) * \vel.kr(1);
	Out.ar(\out.kr(0), sig!2);

}, metadata: (
	specs: (
		freqmul: ControlSpec(1, 4, \lin, 0, 3.99),
		drive: ControlSpec(1, 4, \lin, 0, 1.02),
	)
)).add;

)