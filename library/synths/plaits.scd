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
var func = {|freq, gate, aeg|

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

	var sig = MiPlaits.ar(
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

	sig;
};

S.def(\plaits, func, \perc);
)
