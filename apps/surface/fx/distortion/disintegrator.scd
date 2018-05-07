(
func: {arg in;

	var sig = Disintegrator.ar(in,
		probability: [\probL.kr(0.5),
			\probR.kr(0.5)
		],
		multiplier: [\multL.kr(0),
			\multR.kr(0)
		]
	);
	sig;
},
specs: (
	probL: [0, 1, \lin, 0, 0.5],
	probR: [0, 1, \lin, 0, 0.5],

	multL: [-1, 1, \lin, 0, 0],
	multR: [-1, 1, \lin, 0, 0]
)
)