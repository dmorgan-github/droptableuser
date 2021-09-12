(
// plaits mono synth
SynthDef(\plaits_mono, {

	var gate = \gate.kr(1);
	var freq = \freq.kr(261).lag(\glis.kr(0));
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
    //var level = \level.kr(0.5);

	var note = freq.cpsmidi;
	var sig = MiPlaits.ar(note,
		engine:engine,
		harm:harm,
		timbre: timbre,
		morph:morph,
		trigger:trigger,
        level: 0, //not sure how to make this work
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
    sig = sig * AmpCompA.kr(freq) * \amp.kr(-6.dbamp) * \vel.kr(1);
	sig = Splay.ar(sig, spread: \spread.kr(1), center:\pan.kr(0));
	Out.ar(\out.kr(0), sig);

}, metadata: (
    specs: (
        engine: ControlSpec(0, 15, \lin, 1, 0, "timbre"),
        harm: ControlSpec(0, 1, \lin, 0, 0.1, "timbre"),
        timbre: ControlSpec(0, 1, \lin, 0, 0.1, "timbre"),
        morph: ControlSpec(0, 1, \lin, 0, 0.5, "timbre"),
        fm_mod: ControlSpec(-1, 1, \lin, 0, 0, "fm"),
        timb_mod: ControlSpec(-1, 1, \lin, 0, 0, "timbre"),
        morph_mod: ControlSpec(-1, 1, \lin, 0, 0, "timbre"),
        decay: ControlSpec(0, 1, \lin, 0, 0.5, "env"),
        lpg_colour: ControlSpec(0, 1, \lin, 0, 0.5, "filter")
    )
)).add;
)
