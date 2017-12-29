(
func: {arg in;
	var sig = Squiz.ar(in,
		pitchratio: [\pitchratioL.kr.range(\pitchratioL_min.kr(1), \pitchratioL_max.kr(6)),
			\pitchratioR.kr.range(\pitchratioR_min.kr(1), \pitchratioR_max.kr(6))
		],
		zcperchunk: [\zcperchunkL.kr.range(\zcperchunkL_min.kr(1), \zcperchunkL_max.kr(6)),
			\zcperchunkR.kr.range(\zcperchunkR_min.kr(1), \zcperchunkR_max.kr(6))
		]
	);
	LeakDC.ar(sig);
},
specs: (
	pitchratioL: [1, 6, \lin, 0, 2],
	pitchratioR: [1, 6, \lin, 0, 2],

	zcperchunkL: [1, 6, \lin, 0, 1],
	zcperchunkR: [1, 6, \lin, 0, 1]
)
)
