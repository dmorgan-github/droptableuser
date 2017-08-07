(
func: {
	var freq = \freq.kr.range(\freq_min.kr(0.001), \freq_max.kr(80));
	LFNoise2.kr(freq);
},
specs: [
	freq: [0.001, 80, \lin, 0, 20]
]
)