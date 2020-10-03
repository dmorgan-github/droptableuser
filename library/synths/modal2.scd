(
SynthDef(\modal2, {

	var num = 50;
	var freq = \freq.kr(220);
	var trig = \trig.tr(1);
	var pan = \pan.kr(0);
	var decaycoef = \decaycoef.kr(2);
	var decayscale = \decayscale.kr(0);
	var position = \pos.kr(0.414);
	var harm = \harm.kr(1);
	var bright = \bright.kr(0.5).linlin(0, 1, 80, 8000);
	var k = (1..num);

	var ratios = {
		var val = k * sqrt(1 + ((k).pow(2) * harm));
		val/val[0];
	}.();

	var amps = {
		var val = sin(k * position * pi)
		* (3 * k.log2).dbamp
		* (1 + exp(100 * (ratios-20000)));
		val;
	}.();

	var rings = {
		var val = exp(-1 * (k-1) * decaycoef) + decayscale;
		val/val[0];
	}.();

	var ex = LPF.ar(K2A.ar(trig), bright);

	var sig = DynKlank.ar(`[
		ratios,
		amps,
		rings
	], ex, freq, decayscale:\rel.kr(1));

	sig = Limiter.ar(sig);
	sig = sig * AmpCompA.kr(freq) * \amp.kr(-6.dbamp) * \vel.kr(1);

	DetectSilence.ar(in: sig, doneAction: Done.freeSelf);

	Out.ar(\out.kr(0), Pan2.ar(sig, pan)); d

}, metadata: (
	credit: "adapted from synth by Josh Mitchell",
	type: \perc,
	created: "09/27/2020",
	specs: (
		\harm: ControlSpec(-0.06, 2, \lin, 0, 0),
		\bright: ControlSpec(0, 1, \exp, 0, 0.5)
	)
)).add
)