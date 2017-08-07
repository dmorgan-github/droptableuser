(
func: {arg in;

	var dt = \dt.kr.range(\dt_min.kr(0.001), \dt_max.kr(360)).lag(0.1);
	var decay = \decay.kr.range(\decay_min.kr(0.001), \decay_max.kr(360)).lag(0.1);
	AllpassC.ar(in, dt, dt, decaytime:decay);
},

specs: (
	dt: [0.001, 360, \lin, 0, 0.2],
	decay: [0.001, 360, \lin, 0, 1]
)
)