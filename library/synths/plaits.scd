(
SynthDef(\plaits, {

	var gate = \gate.kr(1);
	var in_freq = \freq.ar(261).lag(\glis.kr(0));
	var detune = \detunehz.kr(0.6) * PinkNoise.ar(0.007).range(0.9, 1.1);
	var bend = \bend.ar(0).midiratio;
	var freqbend = in_freq * bend;
	var freq = Vibrato.ar([freqbend + detune.neg, freqbend + detune], \vrate.ar(6), \vdepth.ar(0.0));

	var osc = {
		var pitch = freq.cpsmidi;
		var engine = \engine.kr(0);
		var harm = \harm.kr(0.1);
		var timbre = \timbre.kr(0.5);
		var morph = \morph.kr(0.5);
		var trigger = \trigger.kr(0);
		var fmmod = \fmmod.kr(0);
		var timbremod = \timbremod.kr(0);
		var morphmod = \morphmod.kr(0);
		var decay = \decay.kr(0.5);
		var lpg = \lpg.kr(0.5);

		MiPlaits.ar(
			pitch,
			engine,
			harm,
			timbre,
			morph,
			trigger,
			fm_mod:fmmod,
			timb_mod:timbremod,
			morph_mod:morphmod,
			decay:decay,
			lpg_colour:lpg
		);
	};

	var adsr = {
		var atk = \atk.kr(0.01);
		var dec = \dec.kr(0);
		var sus = \suslevel.kr(1);
		var rel = \rel.kr(1);
		var curve = \curve.kr(-4);
		Env.adsr(atk, dec, sus,  rel, curve:curve)
		.ar(gate:gate, doneAction:Done.freeSelf);
	};

	var sig = osc.();
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
		engine: ControlSpec(0, 15, \lin, 1, 0),
		harm: ControlSpec(0, 1, \lin, 0, 0.1),
		timbre: ControlSpec(0, 1, \lin, 0, 0.5),
		morph: ControlSpec(0, 1, \lin, 0, 0.5),
		fmmod: ControlSpec(0, 1, \lin, 0, 0),
		timbremod: ControlSpec(0, 1, \lin, 0, 0),
		morphmod: ControlSpec(0, 1, \lin, 0, 0),
		decay: ControlSpec(0, 1, \lin, 0, 0.5),
		lpg: ControlSpec(0, 1, \lin, 0, 0.5),
		trigger: ControlSpec(0, 1, \lin, 1, 0)
	)
)).add;
)