(
func: {arg in;

	var bw = \bw.kr(1);
	var sig = BBandPass.ar(in,
		\freq.kr(1200).clip(20, 20000),
		bw,
		mul:bw.reciprocal.sqrt
	);

	sig;
},
specs: (
	freq: [20, 20000, \lin, 0, 1200],
	bw: [0, 10.0, \lin, 0, 1]
)
)
