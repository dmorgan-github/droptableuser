(
func: {arg in;
	Greyhole.ar(in,
		\delayTime.kr.range(\delayTime_min.kr(0.1), \delayTime_max.kr(60)),
		\damp.kr.range(\damp_min.kr(0), \damp_max.kr(1)),
		\size.kr.range(\size_min.kr(0.5), \size_max.kr(5)),
		\diff.kr.range(\diff_min.kr(0), \diff_max.kr(1)),
		\feedback.kr.range(\feedback_min.kr(0), \feedback_max.kr(1)),
		\modDepth.kr.range(\modDepth_min.kr(0), \modDepth_max.kr(1)),
		\modFreq.kr.range(\modFreq_min.kr(0), \modFreq_max.kr(10))
	)
},
specs: (
	delayTime: [0.1, 60, \lin, 0, 2],
	damp: [0, 1, \lin, 0, 0],
	size: [0.5, 5, \lin, 0, 1],
	diff: [0,1, \lin, 0, 0.707],
	feedback: [0,1, \lin,0, 0.9],
	modDepth: [0, 1, \lin, 0, 0.1],
	modFreq: [0, 10, \lin, 0, 2]
)
)