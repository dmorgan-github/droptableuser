(
func: {arg in;

	GVerb.ar(Mono(in),
		\roomsize.kr.range(\roomsize_min.kr(1), \roomsize_max.kr(300)),
		\revtime.kr.range(\revtime_min.kr(0.1), \revtime_max.kr(10)),
		\damping.kr.range(\damping_min.kr(0), \damping_max.kr(1)),
		\inputbw.kr.range(\inputbw_min.kr(0), \inputbw_max.kr(1)),
		\spread.kr.range(\spread_min.kr(0), \spread_max.kr(90)),
		\drylevel.kr.range(\drylevel_min.kr(0.1), \drylevel_max.kr(1)),
		\earlyreflevel.kr.range(\earlyreflevel_min.kr(0.1), \earlyreflevel_max.kr(1)),
		\taillevel.kr.range(\taillevel_min.kr(0.1), \taillevel_max.kr(10))
	);
},

specs: (
	roomsize: [1, 300, \lin, 1, 40],
	revtime: [0.1, 10, \lin, 0, 4],
	damping: [0, 1, \lin, 0, 0.9],
	inputbw: [0, 1, \lin, 0, 0.75],
	spread: [0, 90, \lin, 0, 15],
	drylevel: [0.1, 1, \lin,0, 1],
	earlyreflevel: [0.1, 1, \lin, 0, 0.07943282347242],
	taillevel: [0.1, 10, \lin, 0, 0.0398107170553]
)
)