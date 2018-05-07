(
func: {arg in;
	var gain = \gain.kr(1);
	(in * gain).tanh;
},
specs: (
	gain: [1, 10, \lin, 0, 1]
)
)