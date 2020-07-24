(
SynthDef(\pm4op1car, {

	// support mono or poly mode
	var trig = Trig1.kr(\trig.tr(1), \sustain.kr(1));
	var gate = Select.kr(\retrig.kr(0), [\gate.kr(1), trig]);
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
		Env.adsr(atk, dec, sus,  rel, curve: curve)
		.ar(gate:gate, doneAction:Done.freeSelf);
	};

	var sig = {

		var op4 = {
			SinOscFB.ar(freq * \op4ratio.kr(1), \fb.kr(0))
			* Env.perc(\op4atk.kr(0.001), \op4rel.kr(1), curve:\op4curve.kr(-4)).ar()
			* \m4.kr(1);
		}.();

		var op3 = {
			SinOsc.ar(freq * \op3ratio.kr(1), op4.mod(2pi))
			* Env.perc(\op3atk.kr(0.001), \op3rel.kr(1), curve:\op3curve.kr(-4)).ar()
			* \m3.kr(1);
		}.();

		var op2 = {
			SinOsc.ar(freq * \op2ratio.kr(1), op3.mod(2pi))
			* Env.perc(\op2atk.kr(0.001), \op2rel.kr(1), curve:\op2curve.kr(-4)).ar()
			* \m2.kr(1);
		}.();

		SinOsc.ar(freq * \op1ratio.kr(1), op2.mod(2pi));
	};

	var aeg = adsr.();

	sig = LeakDC.ar(sig.()) * aeg * \amp.kr(0.3) * \vel.kr(1);
	sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
	Out.ar(\out.kr(0), sig);

}).add;
)
