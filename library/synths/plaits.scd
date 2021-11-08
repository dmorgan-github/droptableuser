(
synth: {|freq, gate, aeg|

    var harm = \harm.kr(0.5);
	var timbre = \timbre.kr(0.5);
	var morph = \morph.kr(0.5);
	var engine = \engine.kr(0);
	var trigger = \trig.tr(1);
	var decay = \decay.kr(0.5);
	var fmmod = \fm_mod.kr(0);
	var timbremod = \timb_mod.kr(0);
	var morphmod = \morph_mod.kr(0);
	var lpg = \lpg.kr(0.5);
    //var level = \level.kr(0.5);

    var note = A2K.kr(freq).cpsmidi;
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
	sig

},
specs: [
    engine: ControlSpec(0, 15, \lin, 1, 0, "timbre"),
    harm: ControlSpec(0, 1, \lin, 0, 0.5, "timbre"),
    timbre: ControlSpec(0, 1, \lin, 0, 0.5, "timbre"),
    morph: ControlSpec(0, 1, \lin, 0, 0.5, "timbre"),
    fm_mod: ControlSpec(-1, 1, \lin, 0, 0, "fm"),
    timb_mod: ControlSpec(-1, 1, \lin, 0, 0, "timbre"),
    morph_mod: ControlSpec(-1, 1, \lin, 0, 0, "timbre"),
    which: ControlSpec(0, 1, \lin, 1, 0, "timbre"),
    focus: ControlSpec(0, 1, \lin, 0, 1, "timbre"),
    decay: ControlSpec(0, 1, \lin, 0, 0.5, "env"),
    lpg: ControlSpec(0, 1, \lin, 0, 0.5, "filter"),
    spread: ControlSpec(0, 1, \lin, 0, 0, "stereo")
]
)