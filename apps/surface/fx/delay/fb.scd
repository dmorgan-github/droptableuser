(
func: {arg in;

	var level = \level.kr.range(\level_min.kr(0.1), \level_max.kr(1));
	var delay = \delay.kr.range(\delay_min.kr(0.001), \delay_max.kr(60));
	var sig = FbC({arg fb; in + fb * level}, delay);
	LeakDC.ar(sig);
},
specs: (
	level: [0.1, 1, \lin, 0, 0.3],
	delay: [0.001, 60, \lin, 0, 0.375]
)
)