(
func: {arg in;
	var gain = \gain.kr(1);
	(in * gain).distort;
},
specs: (
	gain: [1, 10, \lin, 0, 1]
)
)