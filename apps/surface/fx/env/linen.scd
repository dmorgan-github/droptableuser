(
func: {arg in;

	var trig = Impulse.ar(\rate.kr.range(\rate_min.kr(0.01), \rate_max.kr(20)));
	var atk = \atk.kr.range(\atk_min.kr(0.001), \atk_max.kr(8));
	var sus = \sus.kr.range(\sus_min.kr(0.0), \sus_max.kr(8));
	var rel = \rel.kr.range(\rel_min.kr(0.001), \rel_max.kr(8));
	var curve = \curve.kr.range(\curve_min.kr(-20), \curve_max.kr(20));
	var env = Env.linen(attackTime:atk,sustainTime:sus,releaseTime:rel,curve:curve).ar(gate: trig);
	in * env;

},
specs: (
	rate: [0.01,20,\lin,0,1],
	atk: [0.001, 8, \lin, 0, 0.01],
	sus: [0.0, 8, \lin, 0, 1],
	rel: [0.001, 8, \lin, 0, 1],
	curve: [-20, 20, \lin, 0, -4]
)
)