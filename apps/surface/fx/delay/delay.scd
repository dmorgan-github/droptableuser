(
func: {arg in;

	var dt = [\dtL.kr.range(\dtL_min.kr(0.001), \dtL_max.kr(360)).lag(0.1),
		\dtR.kr.range(\dtR_min.kr(0.001), \dtR_max.kr(360)).lag(0.1)];
	var sig = DelayC.ar(in, dt, dt);

	LeakDC.ar(sig);
},

specs: (
	dtL: [0.001, 360, \lin, 0, 0.2],
	dtR: [0.001, 360, \lin, 0, 0.2]
)
)