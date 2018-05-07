(
func: {arg in;

	var sig = JPverb.ar(in,
		t60: [\t60L.kr(1),
			\t60R.kr(1)
		],
		damp: [\dampL.kr(0),
			\dampR.kr(0)
		],
		size: [\sizeL.kr(1),
			\sizeR.kr(1)
		],
		earlyDiff: [\earlyDiffL.kr(0.707),
			\earlyDiffR.kr(0.707)
		],
		modDepth: [\modDepthL.kr,
			\modDepthR.kr
		],
		modFreq: [\modFreqL.kr(0.1),
			\modFreqR.kr(0.1)
		],
		low: [\lowL.kr(1),
			\lowR.kr(1)
		],
		mid: [\midL.kr(1),
			\midR.kr(1)
		],
		high: [\highL.kr(1),
			\highR.kr(1)
		],
		lowcut: [\lowcutL.kr(500),
			\lowcutR.kr(500)
		],
		highcut: [\highcutL.kr(2000),
			\highcutR.kr(2000)
		]
	);

	sig;
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