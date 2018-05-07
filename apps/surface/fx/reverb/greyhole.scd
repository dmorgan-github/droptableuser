(
func: {arg in;
	var sig = Greyhole.ar(in,
		[\delayTimeL.kr(2),
			\delayTimeR.kr(2)
		],
		[\dampL.kr(0),
			\dampR.kr(0)
		],
		[\sizeL.kr(1),
			\sizeR.kr(1)
		],
		[\diffL.kr(0.707),
			\diffR.kr(0.707)
		],
		[\feedbackL.kr(0.9),
			\feedbackR.kr(0.9)
		],
		[\modDepthL.kr(0.1),
			\modDepthR.kr(0.1)
		],
		[\modFreqL.kr(2),
			\modFreqR.kr(2)
		]
	);

	sig;
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