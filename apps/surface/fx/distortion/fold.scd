(
func: {arg in;
	var lo = \lo.kr(-1);
	var hi = \hi.kr(1);
	LeakDC.ar(in.fold(lo, hi));
},
specs: (
	lo: [-1, 0, \lin, 0, -1],
	hi: [0, 1, \lin, 0, 1]
)
)