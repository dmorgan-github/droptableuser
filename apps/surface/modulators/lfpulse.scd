(
func: {
	var freq = \freq.kr;
	var width = \width.kr;
	LFPulse.kr(freq, width:width);
},
specs: (
	freq: [0.001, 80, \lin, 0, 1],
	width: [0, 1, \lin, 0, 0.5]
)
)