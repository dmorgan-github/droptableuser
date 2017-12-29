(
func: {arg in;
	var sig = WaveLoss.ar(in,
		[\dropL.kr.range(\dropL_min.kr(1), \dropL_max.kr(50)),
			\dropR.kr.range(\dropR_min.kr(1), \dropR_max.kr(50))],
		[\outofL.kr.range(\outofL_min.kr(1), \outofL_max.kr(100)),
			\outofR.kr.range(\outofR_min.kr(1), \outofR_max.kr(100))
		],
		[\modeL.kr.range(\modeL_min.kr(1), \modeL_max.kr(2)),
			\modeR.kr.range(\modeR_min.kr(1), \modeR_max.kr(2))
		]
	);
	LeakDC.ar(sig);
},
specs: (
	dropL: [1,50,\lin,1,20],
	dropR: [1,50,\lin,1,20],

	outofL: [1,100,\lin,1,40],
	outofR: [1,100,\lin,1,40],

	modeL: [1,2,\lin,1,1],
	modeR: [1,2,\lin,1,1]
)
)