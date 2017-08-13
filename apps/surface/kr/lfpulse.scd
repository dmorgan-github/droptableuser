(
func: {
	var freq = \freq.kr.range(\freq_min.kr(0.001), \freq_max.kr(80));
	var width = \width.kr.range(\width_min.kr(0), \width_max.kr(1));
	LFPulse.kr(freq, width:width);
},
specs: (
	freq: [0.001, 80, \lin, 0, 1],
	width: [0, 1, \lin, 0, 0.5]
)
)