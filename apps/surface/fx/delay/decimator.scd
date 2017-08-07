(
func: {arg in;
	Decimator.ar(in,
		rate: 44100 * \ratemul.kr.range(\ratemul_min.kr(0.1), \ratemul_max.kr(1)),
		bits: \bits.kr.range(\bits_min.kr(2), \bits_max.kr(24))
	);
},
specs: (
	ratemul: [0.1, 1, \lin, 0, 1],
	bits: [2, 24, \lin, 0, 24]
)
)