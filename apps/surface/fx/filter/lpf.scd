(
func: {arg in;
	var sig =LPF.ar(in,
		\freq.kr.range(\freq_min.kr(20), \freq_max.kr(20000)).clip(20, 20000);
	);

	LeakDC.ar(sig);
},
specs: (
	freq: [20, 20000, \lin, 0, 1000]
)
)