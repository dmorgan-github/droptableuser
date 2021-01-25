/*
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
*/
(
// plaits mono synth
SynthDef(\plaits, {

	var gate = \gate.kr(1);
	var freq = \freq.kr(261);
	var harm = \harm.kr(0.5);
	var timbre = \timbre.kr(0.5);
	var morph = \morph.kr(0.5);
	var engine = \engine.kr(0);
	var trigger = \trig.tr(1);
	var decay = \decay.kr(0.5);
	var fmmod = \fmmod.kr(0);
	var timbremod = \timbremod.kr(0);
	var morphmod = \morphmod.kr(0);
	var lpg = \lpg.kr(0.5);

	var note = freq.cpsmidi;
	var sig = MiPlaits.ar(note,
		engine:engine,
		harm:harm,
		timbre: timbre,
		morph:morph,
		trigger:trigger,
		level: 0,
		fm_mod: fmmod,
		timb_mod: timbremod,
		morph_mod: morphmod,
		decay: decay,
		lpg_colour: lpg
	);
	var pri = sig[0];
	var aux = sig[1];

	sig = SelectXFocus.ar(\which.kr(0), [pri, aux], \focus.kr(1));
	sig = sig * Env.asr.ar(gate:gate, doneAction:Done.freeSelf);
	sig = sig * AmpCompA.kr(freq) * \amp.kr(-6.dbamp);
	sig = Splay.ar(sig, spread: \spread.kr(1), center:\pan.kr(0));
	Out.ar(\out.kr(0), sig);

}).add;
)
