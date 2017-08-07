(
func: {arg in;

	JPverb.ar(in,
		t60: \t60.kr.range(\t60_min.kr(0.1), \t60_max.kr(60)),
		damp: \damp.kr.range(\damp_min.kr(0), \damp_max.kr(1)),
		size: \size.kr.range(\size_min.kr(0.5), \size_max.kr(5)),
		earlyDiff: \earlyDiff.kr.range(\earlyDiff_min.kr(0), \earlyDiff_max.kr(1)),
		modDepth: \modDepth.kr.range(\modDepth_min.kr(0), \modDepth_max.kr(1)),
		modFreq: \modFreq.kr.range(\modFreq_min.kr(0), \modFreq_max.kr(10)),
		low: \low.kr.range(\low_min.kr(0), \low_max.kr(1)),
		mid: \mid.kr.range(\mid_min.kr(0), \mid_max.kr(1)),
		high: \high.kr.range(\high_min.kr(0), \high_max.kr(1)),
		lowcut: \lowcut.kr.range(\lowcut_min.kr(100), \lowcut_max.kr(6000)),
		highcut: \highcut.kr.range(\highcut_min.kr(1000), \highcut_max.kr(10000))
	);
},
specs: (
	t60: [0.1, 60, \lin, 0.01, 1],
	damp: [0, 1, \lin, 0.001, 0],
	size: [0.5, 5, \lin, 0.1, 1],
	earlyDiff: [0, 1, \lin, 0.01, 0.707],
	modDepth: [0, 1, \lin, 0.01, 0.1],
	modFreq: [0, 10, \lin, 0.1, 2],
	low: [0, 1, \lin, 0.01, 1],
	mid: [0, 1, \lin, 0.01, 1],
	high: [0, 1, \lin, 0.01, 1],
	lowcut: [100, 6000, \exp, 1, 500],
	highcut: [1000, 10000, \exp, 1, 2000]
)
)