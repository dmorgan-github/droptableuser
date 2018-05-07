(
func: {arg in;

	var sig = DFM1.ar(in,
		\freq.kr(1000).clip(20, 20000);,
		\res.kr(0.1),
		\inputgain.kr(1),
		\type.kr(0),
		\noiselevel.kr(0.0003)
	);

	sig;
},
specs: (
	freq: [20, 20000, \lin, 0, 1000],
	res: [0.01, 4, \lin, 0, 0.1],
	inputgain: [0.1, 2, \lin, 0, 1],
	type: [0, 1, \lin, 1, 0],
	noiselevel: [0.0001, 1, \lin, 0.0001, 0.0003]
)
)