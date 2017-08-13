(
func: {arg in;
	var lo = \lo.kr.range(\lo_min.kr(-1), \lo_max.kr(0));
	var hi = \hi.kr.range(\hi_min.kr(0), \hi_max.kr(1));
	in.wrap(lo, hi);
},
specs: (
	lo: [-1, 0, \lin, 0, -1],
	hi: [0, 1, \lin, 0, 1]
)
)