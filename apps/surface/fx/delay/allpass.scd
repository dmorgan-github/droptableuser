(
func: {arg in;

	var dt = [\dtL.kr.range(\dtL_min.kr(0.001), \dtL_max.kr(360)).lag(0.1),
		\dtR.kr.range(\dtR_min.kr(0.001), \dtR_max.kr(360)).lag(0.1)
	];
	var decay = [\decayL.kr.range(\decayL_min.kr(0.001), \decayL_max.kr(360)).lag(0.1),
		\decayR.kr.range(\decayR_min.kr(0.001), \decayR_max.kr(360)).lag(0.1)
	];
	var sig = AllpassC.ar(in, dt, dt, decaytime:decay);
	LeakDC.ar(sig);
},

specs: (
	dtL: [0.001, 360, \lin, 0, 0.2],
	dtR: [0.001, 360, \lin, 0, 0.2],

	decayL: [0.001, 360, \lin, 0, 1],
	decayR: [0.001, 360, \lin, 0, 1]
)
)
