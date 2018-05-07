(
func: {arg in;

	var sig = CrossoverDistortion.ar(in,
		amp: [\ampL.kr(0.5), \ampR.kr(0.5)],
		smooth: [\smoothL.kr(0.5), \smoothR.kr(0.5)]
	);

	LeakDC.ar(sig) * 0.1
},
specs: (
	ampL: [0, 1, \lin, 0, 0.5],
	ampR: [0, 1, \lin, 0, 0.5],

	smoothL: [0, 1, \lin, 0, 0.5],
	smoothR: [0, 1, \lin, 0, 0.5]
)
)