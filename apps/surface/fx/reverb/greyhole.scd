(
func: {arg in;
	Greyhole.ar(in,
		[\delayTimeL.kr.range(\delayTimeL_min.kr(0.1), \delayTimeL_max.kr(60)).lag(0.1),
			\delayTimeR.kr.range(\delayTimeR_min.kr(0.1), \delayTimeR_max.kr(60)).lag(0.1)],
		[\dampL.kr.range(\dampL_min.kr(0), \dampL_max.kr(1)),
			\dampR.kr.range(\dampR_min.kr(0), \dampR_max.kr(1))],
		[\sizeL.kr.range(\sizeL_min.kr(0.5), \sizeL_max.kr(5)).lag(0.1),
			\sizeR.kr.range(\sizeR_min.kr(0.5), \sizeR_max.kr(5)).lag(0.1)],
		[\diffL.kr.range(\diffL_min.kr(0), \diffL_max.kr(1)),
			\diffR.kr.range(\diffR_min.kr(0), \diffR_max.kr(1))],
		[\feedbackL.kr.range(\feedbackL_min.kr(0), \feedbackL_max.kr(1)),
			\feedbackR.kr.range(\feedbackR_min.kr(0), \feedbackR_max.kr(1))],
		[\modDepthL.kr.range(\modDepthL_min.kr(0), \modDepthL_max.kr(1)),
			\modDepthR.kr.range(\modDepthR_min.kr(0), \modDepthR_max.kr(1))],
		[\modFreqL.kr.range(\modFreqL_min.kr(0), \modFreqL_max.kr(10)),
			\modFreqR.kr.range(\modFreqR_min.kr(0), \modFreqR_max.kr(10))]
	)
},
specs: (
	delayTimeL: [0.1, 60, \lin, 0, 2],
	delayTimeR: [0.1, 60, \lin, 0, 2],

	dampL: [0, 1, \lin, 0, 0],
	dampR: [0, 1, \lin, 0, 0],

	sizeL: [0.5, 5, \lin, 0, 1],
	sizeR: [0.5, 5, \lin, 0, 1],

	diffL: [0,1, \lin, 0, 0.707],
	diffR: [0,1, \lin, 0, 0.707],

	feedbackL: [0,1, \lin,0, 0.9],
	feedbackR: [0,1, \lin,0, 0.9],

	modDepthL: [0, 1, \lin, 0, 0.1],
	modDepthR: [0, 1, \lin, 0, 0.1],

	modFreqL: [0, 10, \lin, 0, 2],
	modFreqR: [0, 10, \lin, 0, 2]
)
)