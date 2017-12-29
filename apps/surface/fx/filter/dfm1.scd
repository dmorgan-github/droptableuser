(
func: {arg in;

	var sig = DFM1.ar(in,
		\freq.kr.range(\freq_min.kr(20), \freq_max.kr(20000)).lag(0.1),
		\res.kr.range(\res_min.kr(0.01), \res_max.kr(4)).lag(0.1),
		\inputgain.kr.range(\inputgain_min.kr(0.1), \inputgain_max.kr(2)),
		\type.kr.range(\type_min.kr(0), \type_max.kr(1)),
		\noiselevel.kr.range(\noiselevel_min.kr(0.0001), \noiselevel_max.kr(1))
	);

	LeakDC.ar(sig);
},
specs: (
	freq: [20, 20000, \lin, 0, 1000],
	res: [0.01, 4, \lin, 0, 0.1],
	inputgain: [0.1, 2, \lin, 0, 1],
	type: [0, 1, \lin, 1, 0],
	noiselevel: [0.0001, 1, \lin, 0.0001, 0.0003]
)
)