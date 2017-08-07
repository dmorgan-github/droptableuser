(
func: {arg in;

	var dt = \dt.kr.range(\dt_min.kr(0.001), \dt_max.kr(360)).lag(0.1);
	DelayC.ar(in, dt, dt);
},

specs: (
	dt: [0.001, 360, \lin, 0, 0.2]
)
)