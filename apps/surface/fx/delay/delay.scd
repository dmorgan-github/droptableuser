(
func: {arg in;

	var dt = [\dtL.kr(0.2),
		\dtR.kr(0.2)
	];
	var sig = DelayC.ar(in, dt, dt);

	sig;
},

specs: (
	dtL: [0.001, 360, \lin, 0, 0.2],
	dtR: [0.001, 360, \lin, 0, 0.2]
)
)