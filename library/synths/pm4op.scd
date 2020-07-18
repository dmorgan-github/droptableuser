(
SynthDef(\pm4op, {

	var gate = \gate.kr(1);
	var in_freq = \freq.ar(261).lag(\glis.kr(0));
	var detune = \detunehz.kr(0.6) * PinkNoise.ar(0.007).range(0.9, 1.1);
	var bend = \bend.ar(0).midiratio;
	var freqbend = in_freq * bend;
	var freq = Vibrato.ar([freqbend + detune.neg, freqbend + detune], \vrate.ar(6), \vdepth.ar(0.0));

	var osc4 = SinOscFB.ar(freq, \fb.kr(0.8)) * Env.perc(0.01, 1, curve:-4).ar() * \m4.kr(1);
	var osc3 = SinOsc.ar(freq, osc4.mod(2pi));

	var osc2 = SinOsc.ar(freq * 2.01) * Env.perc(0.01, 1, curve:-4).ar(
		gate:gate
	) * \m2.kr(1);
	var osc1 = SinOsc.ar(freq, osc2.mod(2pi));

	var adsr = {
		var atk = \atk.kr(0.01);
		var dec = \dec.kr(0);
		var sus = \suslevel.kr(1);
		var rel = \rel.kr(1);
		var curve = \curve.kr(-4);
		Env.adsr(atk, dec, sus,  rel, curve:curve)
		.ar(gate:gate, doneAction:Done.freeSelf);
	};

	var sig = osc1 + osc3;
	var aeg = adsr.();

	var drive = \drive.kr(1).max(1);
	sig = Select.ar( (drive > 1), [
		sig,
		LeakDC.ar((sig * drive).softclip) * drive.sqrt.reciprocal
	]);
	sig = sig * aeg * \amp.kr(0.3) * \vel.kr(1);

	sig = BLowPass.ar(
		BHiPass.ar(sig,
			\hpf.kr(20).clip(20, 18000),
			\hpfres.kr(0).linlin(0, 1, 1.4, 0.001)
		),
		\lpf.kr(20000).clip(20, 20000),
		\lpfres.kr(0).linlin(0, 1, 1.4, 0.001)
	);

	sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
	Out.ar(\out.kr(0), sig);

}, metadata: (
	specs: (
		fb: ControlSpec(-1, 1, 0, \lin, 0, 0.3),
		m4: ControlSpec(0, 2pi, \lin, 0, 0.5pi),
		m2: ControlSpec(0, 2pi, \lin, 0, 0.5pi),
		fb: ControlSpec(0, 1, \lin, 0, 0.5)
	)
)).add;
)