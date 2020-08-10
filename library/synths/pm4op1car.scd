(
SynthDef(\pm4op1car, {

	// support mono or poly mode
	//var trig = Trig1.kr(\trig.tr(1), \sustain.kr(1));
	//var gate = Select.kr(\retrig.kr(0), [\gate.kr(1), trig]);
	var in_freq = \freq.ar(261).lag(\glis.kr(0));
	var detune = \detunehz.kr(0.6) * PinkNoise.ar(0.007).range(0.9, 1.1);
	var bend = \bend.ar(0).midiratio;
	var freqbend = in_freq * bend;
	var freq = Vibrato.ar([freqbend + detune.neg, freqbend + detune], \vrate.ar(6), \vdepth.ar(0.0));

	var adsr = {
		var atk = \atk.kr(0.01);
		var dec = \dec.kr(0);
		var sus = \suslevel.kr(1);
		var rel = \rel.kr(1);
		var curve = \curve.kr(-4);
		//Env.adsr(atk, dec, sus,  rel, curve: curve)
		//.ar(gate:gate, doneAction:Done.freeSelf);
		Env.perc(atk, releaseTime:rel, curve:curve).ar(doneAction:Done.freeSelf);
	};

	var sig = {

		var op4 = {
			SinOscFB.ar(freq * \op4ratio.kr(1), \fb.kr(0))
			//* Env.asr(\op4atk.kr(0.001), \op4suslevel.kr(1), \op4rel.kr(1), curve:\op4curve.kr(-4)).ar(gate:gate)
			* Env.perc(\op4atk.kr(0.001), \op4rel.kr(1), curve:\op4curve.kr(-4)).ar()
			* \m4.kr(1);
		}.();

		var op3 = {
			SinOsc.ar(freq * \op3ratio.kr(1), op4.mod(2pi))
			//* Env.asr(\op3atk.kr(0.001), \op3suslevel.kr(1), \op3rel.kr(1), curve:\op3curve.kr(-4)).ar(gate:gate)
			* Env.perc(\op3atk.kr(0.001), \op3rel.kr(1), curve:\op3curve.kr(-4)).ar()
			* \m3.kr(1);
		}.();

		var op2 = {
			SinOsc.ar(freq * \op2ratio.kr(1), op3.mod(2pi))
			//* Env.asr(\op2atk.kr(0.001), \op2suslevel.kr(1), \op2rel.kr(1), curve:\op2curve.kr(-4)).ar(gate:gate)
			* Env.perc(\op2atk.kr(0.001), \op2rel.kr(1), curve:\op2curve.kr(-4)).ar()
			* \m2.kr(1);
		}.();

		SinOsc.ar(freq * \op1ratio.kr(1), op2.mod(2pi));
	};

	var aeg = adsr.();

	sig = LeakDC.ar(sig.()) * aeg * \amp.kr(0.3) * \vel.kr(1);
	sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
	Out.ar(\out.kr(0), sig);

}, metadata: (
	specs: (

		atk: [0.0, 1.0, \lin, 0, 0.01, "aeg"].asSpec,
		dec: [0.0, 1.0, \lin, 0, 0.2, "aeg"].asSpec,
		rel: [0.0, 8.0, \lin, 0, 0.29, "aeg"].asSpec,
		suslevel: [0.0, 1.0, \lin, 0, 1, "aeg"].asSpec,
		curve: [-8.0, 8.0, \lin, 0, -4, "aeg"].asSpec,
		ts: [0.001, 100.0, \lin, 0, 1, "aeg"].asSpec,

		op4ratio: [-24.midiratio, 24.midiratio, \lin, 0, 0.midiratio, "op4"].asSpec,
		op4atk: [0.001, 1.0, \exp, 0, 0.01, "op4"].asSpec,
		op4suslevel: [0.0, 1.0, \lin, 0, 1, "op4"].asSpec,
		op4rel: [0.1, 8.0, \exp, 0, 0.29, "op4"].asSpec,
		op4curve: [-8.0, 8.0, \lin, 0, -4, "op4"].asSpec,
		m4: [0.0, 2pi, \exp, 0, 0.1pi, "m4"].asSpec,
		fb: [0.0, 1, \exp, 0, 0.1, "fb"].asSpec,

		op3ratio: [-24.midiratio, 24.midiratio, \lin, 0, 0.midiratio, "op3"].asSpec,
		op3atk: [0.001, 1.0, \exp, 0, 0.01, "op3"].asSpec,
		op3suslevel: [0.0, 1.0, \lin, 0, 1, "op3"].asSpec,
		op3rel: [0.1, 8.0, \exp, 0, 0.29, "op3"].asSpec,
		op3curve: [-8.0, 8.0, \lin, 0, -4, "op3"].asSpec,
		m3: [0.0, 2pi, \exp, 0, 0.1pi, "m3"].asSpec,

		op2ratio: [-24.midiratio, 24.midiratio, \lin, 0, 0.midiratio, "op2"].asSpec,
		op2atk: [0.001, 1.0, \exp, 0, 0.01, "op2"].asSpec,
		op2suslevel: [0.0, 1.0, \lin, 0, 1, "op2"].asSpec,
		op2rel: [0.1, 8.0, \exp, 0, 0.29, "op2"].asSpec,
		op2curve: [-8.0, 8.0, \lin, 0, -4, "op2"].asSpec,
		m2: [0.0, 2pi, \exp, 0, 0.1pi, "m2"].asSpec,

		op1ratio: [-24.midiratio, 24.midiratio, \lin, 0, 0.midiratio, "op1"].asSpec,

		glis: [0.0, 1.0, \lin, 0, 0, "freq"].asSpec,
		detunehz: [0.0, 10.0, \lin, 0, 0, "freq"].asSpec,
		bend: [-12.0, 12.0, \lin, 0, 0, "freq"].asSpec, // semitones
		vrate: [0.0, 440.0, \lin, 0, 6, "freq"].asSpec,
		vdepth: [0.0, 1.0, \lin, 0, 0, "freq"].asSpec,
		spread: [0.0, 1.0, \lin, 0, 1, "stereo"].asSpec,
		center: [0.0, 1.0, \lin, 0, 0, "stereo"].asSpec,
		vel: [0.0, 1.0, \lin, 0, 1, "vol"].asSpec,
		amp: [0.0, 1.0, \lin, 0, -10.dbamp, "vol"].asSpec,
		drive: [1.0, 100.0, \lin, 0, 1, "vol"].asSpec
	)
) ).add;
)
