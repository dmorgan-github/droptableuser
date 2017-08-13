(
func: {arg in;
	Decimator.ar(in,
		rate: 44100 * [\ratemulL.kr.range(\ratemulL_min.kr(0.1), \ratemulL_max.kr(1)),
			\ratemulR.kr.range(\ratemulR_min.kr(0.1), \ratemulR_max.kr(1))
		],
		bits: [\bitsL.kr.range(\bitsL_min.kr(2), \bitsL_max.kr(24)),
			\bitsR.kr.range(\bitsR_min.kr(2), \bitsR_max.kr(24))
		]
	);
},
specs: (
	ratemulL: [0.1, 1, \lin, 0, 1],
	ratemulR: [0.1, 1, \lin, 0, 1],

	bitsL: [2, 24, \lin, 0, 24],
	bitsR: [2, 24, \lin, 0, 24]
)
)