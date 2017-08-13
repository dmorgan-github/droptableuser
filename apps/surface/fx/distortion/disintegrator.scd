(
func: {arg in;
Disintegrator.ar(in,
	probability: [\probL.kr.range(\probL_min.kr(0), \probL_max.kr(1)),
		\probR.kr.range(\probR_min.kr(0), \probR_max.kr(1))
	],
	multiplier: [\multL.kr.range(\multL_min.kr(-1), \multL_max.kr(1)),
		\multR.kr.range(\multR_min.kr(-1), \multR_max.kr(1))
	]
)
},
specs: (
	probL: [0, 1, \lin, 0, 0.5],
	probR: [0, 1, \lin, 0, 0.5],

	multL: [-1, 1, \lin, 0, 0],
	multR: [-1, 1, \lin, 0, 0]
)
)