(
func: {arg in;

	LADSPA.ar(1, 1217,
		\rate.kr.range(\rate_min.kr(0), \rate_max.kr(100)),
		\depth.kr.range(\depth_min.kr(0), \depth_max.kr(1)),
		\feedback.kr.range(\feedback_min.kr(-1), \feedback_max.kr(1)),
		\spread.kr.range(\spread_min.kr(0), \spread_max.kr(2)),
		in
	);
},
specs: (
	rate: [0, 100, \lin, 0, 1],
	depth: [0, 1, \lin, 0, 0.5],
	feedback: [-1, 1, \lin, 0, 0],
	spread: [0, 2, \lin, 0, 0.1]
)
)