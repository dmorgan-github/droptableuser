(
func: {arg in;

	//BRF.ar(in,
	//	\freq.kr.range(\freq_min.kr(20), \freq_max.kr(20000)).clip(20, 20000),
	//	\rq.kr.range(\rq_min.kr(0), \rq_max.kr(1))
	//)
	var sig = BBandStop.ar(in,
		\freq.kr.range(\freq_min.kr(20), \freq_max.kr(20000)).clip(20, 20000),
		\bw.kr.range(\bw_min.kr(0), \bw_ma.kr(10))
	);

	LeakDC.ar(sig);
},
specs: (
	freq: [20, 20000, \lin, 0, 1000],
	bw: [0, 10.0, \lin, 0, 1]
)
)