(
func: {arg in;
	Splay.ar(in,
		\spread.kr.range(\spread_min.kr(0), \spread_max.kr(1)),
		1,
		\center.kr(0)
	);
},

specs: (
	\spread: [0, 1, \lin, 0, 1],
	\center: [-1, 1, \lin, 0, 0]
)
)