(
SynthDef(\pm6algo9, {

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

		var op6 = {
			SinOsc.ar(freq * \op6ratio.kr(1))
			/* Env.asr(
				\op6atk.kr(0.01),
				\op6suslevel.kr(1),
				\op6rel.kr(1),
				\op6curve.kr(-4)
			).ar(gate:gate)
			*/
			* Env.perc(
				\op6atk.kr(0.01),
				\op6rel.kr(1),
				curve:\op6curve.kr(-4)
			).ar(gate:gate)
			* \m6.kr(1);
		};

		var op5 = {
			var mod = op6.();
			SinOsc.ar(freq * \op5ratio.kr(1), mod.mod(2pi))
			* Env.asr(
				\op5atk.kr(0.01),
				\op5suslevel.kr(1),
				\op5rel.kr(1),
				\op5curve.kr(-4)
			).ar(gate:gate)
			/* Env.perc(
				\op5atk.kr(0.01),
				\op5rel.kr(1),
				curve:\op5curve.kr(-4)
			).ar(gate:gate)
			*/
			* \m5.kr(1);
		};

		var op4 = {
			SinOsc.ar(freq * \op4ratio.kr(1))
			* Env.asr(
				\op4atk.kr(0.01),
				\op4suslevel.kr(1),
				\op4rel.kr(1),
				\op4curve.kr(-4)
			).ar(gate:gate)
			/* Env.perc(
				\op4atk.kr(0.01),
				\op4rel.kr(1),
				curve:\op4curve.kr(-4)
			).ar(gate:gate)
			*/
			* \m4.kr(1);
		};

		var op3 = {
			var mod =  op4.() + op5.();
			SinOsc.ar(freq * \op3ratio.kr(1), mod.mod(2pi));
		};

		var op2 = {
			SinOscFB.ar(freq * \op2ratio.kr(1), \fb.kr(0))
			* Env.asr(
				\op2atk.kr(0.01),
				\op2suslevel.kr(1),
				\op2rel.kr(1),
				\op2curve.kr(-4)
			).ar(gate:gate)
			* \m2.kr(1);
		};

		var op1 = {
			var mod = op2.();
			SinOsc.ar(freq * \op1ratio.kr(1), mod.mod(2pi));
		};

		var sig = [
			op1.(),
			op3.()
		] * [\op1.kr(1), \op3.kr(1)].normalizeSum;

		sig.sum;
	};

	var aeg = adsr.();

	sig = LeakDC.ar(sig.());

	sig = LPF.ar(sig, \lpf.kr(20000));

	sig = sig * aeg * AmpCompA.kr(freq, 32) * \amp.kr(0.3) * \vel.kr(1);

	sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
	Out.ar(\out.kr(0), sig);

}).add;
)