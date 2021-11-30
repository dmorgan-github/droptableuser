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

	sig = XFade2.ar([pri, aux], \which.kr(0));
	sig

},
specs: [
    engine: ControlSpec(0, 15, \lin, 1, 0, "plaits"),
    harm: ControlSpec(0, 1, \lin, 0, 0.5, "plaits"),
    timbre: ControlSpec(0, 1, \lin, 0, 0.5, "plaits"),
    morph: ControlSpec(0, 1, \lin, 0, 0.5, "plaits"),
    fm_mod: ControlSpec(-1, 1, \lin, 0, 0, "plaits"),
    timb_mod: ControlSpec(-1, 1, \lin, 0, 0, "plaits"),
    morph_mod: ControlSpec(-1, 1, \lin, 0, 0, "plaits"),
    which: ControlSpec(0, 1, \lin, 1, 0, "plaits"),
    decay: ControlSpec(0, 1, \lin, 0, 0.5, "plaits"),
    lpg: ControlSpec(0, 1, \lin, 0, 0.5, "plaits")
],
presets: [
    bd: [
        'fm_mod': 0.23232323232323,
        'harm': 0.5,
        'morph': 0.5,
        'lpg': 0.68350168350168,
        'engine': 13.0,
        'timb_mod': 0.0,
        'decay': 0.28619528619529,
        'timbre': 0.62289562289562,
        'morph_mod': 0.0
    ],
    sn: [
        'fm_mod': 0.43852459016393,
        'harm': 0.57581967213115,
        'morph': 0.13729508196721,
        'lpg': 0.25204918032787,
        'engine': 14.0,
        'timb_mod': -0.20081967213115,
        'decay': 0.45286885245902,
        'timbre': 0.17827868852459,
        'morph_mod': -0.89344262295082
    ],
    hh: [
        'fm_mod': 0.25659472422062,
        'harm': 0.82254196642686,
        'morph': 0.079136690647482,
        'lpg': 0.8705035971223,
        'engine': 15.0,
        'timb_mod': 0.0,
        'decay': 0.033573141486811,
        'timbre': 0.96402877697842,
        'morph_mod': 0.0
    ]
]
)


