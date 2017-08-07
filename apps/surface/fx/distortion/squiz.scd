(
func: {arg in;
	Squiz.ar(in,
		pitchratio: \pitchratio.kr.range(\pitchratio_min.kr(1), \pitchratio_max.kr(6)),
		zcperchunk: \zcperchunk.kr.range(\zcperchunk_min.kr(1), \zcperchunk_max.kr(6))
	);
},
specs: (
	pitchratio: [1, 6, \lin, 0, 2],
	zcperchunk: [1, 6, \lin, 0, 1]
)
)
