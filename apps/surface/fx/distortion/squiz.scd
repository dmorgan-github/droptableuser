(
func: {arg in;
	var sig = Squiz.ar(in,
		pitchratio: [\pitchratioL.kr(2),
			\pitchratioR.kr(2)
		],
		zcperchunk: [\zcperchunkL.kr(1),
			\zcperchunkR.kr(1)
		]
	);
	sig;
},
specs: (
	pitchratioL: [1, 6, \lin, 0, 2],
	pitchratioR: [1, 6, \lin, 0, 2],

	zcperchunkL: [1, 6, \lin, 0, 1],
	zcperchunkR: [1, 6, \lin, 0, 1]
)
)
