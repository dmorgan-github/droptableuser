(
func: {arg in;
	var gain = [\gainL.kr(1),
		\gainR.kr(1)
	];
	(in * gain).atan;
},
specs: (
	gainL: [1, 10, \lin, 0, 1],
	gainR: [1, 10, \lin, 0, 1]
)
)