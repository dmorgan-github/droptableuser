(
func: {arg in;

	var sig = CrossoverDistortion.ar(in,
		amp: \amp.kr(0.5),
		smooth: smoothL.kr(0.5)
	);

	LeakDC.ar(sig) * 0.1;
},
specs: (
	amp: [0, 1, \lin, 0, 0.5],
	smooth: [0, 1, \lin, 0, 0.5]
)
)