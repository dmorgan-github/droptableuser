(
func: {arg in;
	var sig = WaveLoss.ar(in,
		[\dropL.kr(20),
			\dropR.kr(20)
		],
		[\outofL.kr(40),
			\outofR.kr(40)
		],
		[\modeL.kr(1),
			\modeR.kr(1)
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