(
func: {arg in;

	var sig = Decimator.ar(in,
		rate: 44100 * [\ratemulL.kr(1),
			\ratemulR.kr(1)
		],
		bits: [\bitsL.kr(24),
			\bitsR.kr(24)
		]
	);

	LeakDC.ar(sig);
},
specs: (
	ratemulL: [0.1, 1, \lin, 0, 1],
	ratemulR: [0.1, 1, \lin, 0, 1],

	bitsL: [2, 24, \lin, 0, 24],
	bitsR: [2, 24, \lin, 0, 24]
)
)