(
func: {arg in;

	var sig = CrossoverDistortion.ar(in,
		amp: [\ampL.kr.range(), \ampR.kr.range()],
		smooth: [\smoothL.kr.range(), \smoothR.kr.range()]
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