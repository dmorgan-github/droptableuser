(
func: {arg in;
	var gain = \gain.kr.range(\gain_min.kr(1), \gain_max.kr(10));
	(in * gain).atan;
},
specs: [
	gain: [1, 10, \lin, 0, 1]
]
)