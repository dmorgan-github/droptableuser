(
func: {arg in;

	var sig = JPverb.ar(in,
		t60: [\t60L.kr.range(\t60L_min.kr(0.1), \t60L_max.kr(60)),
			\t60R.kr.range(\t60R_min.kr(0.1), \t60R_max.kr(60))
		],
		damp: [\dampL.kr.range(\dampL_min.kr(0), \dampL_max.kr(1)),
			\dampR.kr.range(\dampR_min.kr(0), \dampR_max.kr(1))
		],
		size: [\sizeL.kr.range(\sizeL_min.kr(0.5), \sizeL_max.kr(5)).lag(0.1),
			\sizeR.kr.range(\sizeR_min.kr(0.5), \sizeR_max.kr(5)).lag(0.1)
		],
		earlyDiff: [\earlyDiffL.kr.range(\earlyDiffL_min.kr(0), \earlyDiffL_max.kr(1)),
			\earlyDiffR.kr.range(\earlyDiffR_min.kr(0), \earlyDiffR_max.kr(1))
		],
		modDepth: [\modDepthL.kr.range(\modDepthL_min.kr(0), \modDepthL_max.kr(1)),
			\modDepthR.kr.range(\modDepthR_min.kr(0), \modDepthR_max.kr(1))
		],
		modFreq: [\modFreqL.kr.range(\modFreqL_min.kr(0), \modFreqL_max.kr(10)),
			\modFreqR.kr.range(\modFreqR_min.kr(0), \modFreqR_max.kr(10))
		],
		low: [\lowL.kr.range(\lowL_min.kr(0), \lowL_max.kr(1)),
			\lowR.kr.range(\lowR_min.kr(0), \lowR_max.kr(1))
		],
		mid: [\midL.kr.range(\midL_min.kr(0), \midL_max.kr(1)),
			\midR.kr.range(\midR_min.kr(0), \midR_max.kr(1))
		],
		high: [\highL.kr.range(\highL_min.kr(0), \highL_max.kr(1)),
			\highR.kr.range(\highR_min.kr(0), \highR_max.kr(1))
		],
		lowcut: [\lowcutL.kr.range(\lowcutL_min.kr(100), \lowcutL_max.kr(6000)),
			\lowcutR.kr.range(\lowcutR_min.kr(100), \lowcutR_max.kr(6000))
		],
		highcut: [\highcutL.kr.range(\highcutL_min.kr(1000), \highcutL_max.kr(10000)),
			\highcutR.kr.range(\highcutR_min.kr(1000), \highcutR_max.kr(10000))
		]
	);

	LeakDC.ar(sig);
},
specs: (
	t60L: [0.1, 60, \lin, 0.01, 1],
	t60R: [0.1, 60, \lin, 0.01, 1],

	dampL: [0, 1, \lin, 0.001, 0],
	dampR: [0, 1, \lin, 0.001, 0],

	sizeL: [0.5, 5, \lin, 0.1, 1],
	sizeR: [0.5, 5, \lin, 0.1, 1],

	earlyDiffL: [0, 1, \lin, 0.01, 0.707],
	earlyDiffR: [0, 1, \lin, 0.01, 0.707],

	modDepthL: [0, 1, \lin, 0.01, 0.1],
	modDepthR: [0, 1, \lin, 0.01, 0.1],

	modFreqL: [0, 10, \lin, 0.1, 2],
	modFreqR: [0, 10, \lin, 0.1, 2],

	lowL: [0, 1, \lin, 0.01, 1],
	lowR: [0, 1, \lin, 0.01, 1],

	midL: [0, 1, \lin, 0.01, 1],
	midR: [0, 1, \lin, 0.01, 1],

	highL: [0, 1, \lin, 0.01, 1],
	highR: [0, 1, \lin, 0.01, 1],

	lowcutL: [100, 6000, \exp, 1, 500],
	lowcutR: [100, 6000, \exp, 1, 500],

	highcutL: [1000, 10000, \exp, 1, 2000],
	highcutR: [1000, 10000, \exp, 1, 2000]
)
)