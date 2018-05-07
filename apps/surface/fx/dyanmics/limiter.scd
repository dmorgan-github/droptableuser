(
func: {arg in;
	var level = \level.kr.range(\level_min.kr(0), \level_max.kr(1));
	var sig = Limiter.ar(in, level, 0.01);
	LeakDC.ar(sig);
},
specs: (
	level: [0, 1, \lin, 0, 0.8]
)
)