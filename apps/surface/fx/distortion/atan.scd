(
func: {arg in;
	var gain = [\gainL.kr.range(\gainL_min.kr(1), \gainL_max.kr(10)),
		\gainR.kr.range(\gainR_min.kr(1), \gainR_max.kr(10))
	];
	(in * gain).atan;
},
specs: (
	gainL: [1, 10, \lin, 0, 1]
	gainR: [1, 10, \lin, 0, 1]
)
)