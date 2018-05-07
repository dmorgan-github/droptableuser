(
func: {arg in;

	var dt = [\dtL.kr(0.2),
		\dtR.kr(0.2)
	];
	var decay = [\decayL.kr(1),
		\decayR.kr(1)
	];
	var sig = AllpassC.ar(in, dt, dt, decaytime:decay);
	sig;
},

specs: (
	dtL: [0.001, 360, \lin, 0, 0.2],
	dtR: [0.001, 360, \lin, 0, 0.2],

	decayL: [0.001, 360, \lin, 0, 1],
	decayR: [0.001, 360, \lin, 0, 1]
)
)
