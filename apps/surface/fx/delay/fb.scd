(
func: {arg in;

	var level = \level.kr;
	var delay = \delay.kr;
	var sig = FbC({arg fb; in + fb * level}, delay);
	sig;
},
specs: (
	level: [0.1, 1, \lin, 0, 0.3],
	delay: [0.001, 60, \lin, 0, 0.375]
)
)