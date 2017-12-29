/*
(
GVerb.ar(
	in: a*LFNoise1.ar(40),
	roomsize: 400,
	revtime: 400,
	damping: 0.2,
	inputbw: 0.5,
	spread: 50,
	drylevel: 0,
	earlyreflevel: 0.2,
	taillevel: 0.9,
	maxroomsize: 400)
)
*/

(
func: {arg in;

	var sig = GVerb.ar(Mix.ar(in),
		400, //\roomsize.kr.range(\roomsize_min.kr(1), \roomsize_max.kr(300)),
		[\revtimeL.kr.range(\revtimeL_min.kr(0.1), \revtimeL_max.kr(1000)),
			\revtimeR.kr.range(\revtimeR_min.kr(0.1), \revtimeR_max.kr(1000))],
		[\dampingL.kr.range(\dampingL_min.kr(0), \dampingL_max.kr(1)),
			\dampingR.kr.range(\dampingR_min.kr(0), \dampingR_max.kr(1))
		],
		[\inputbwL.kr.range(\inputbwL_min.kr(0), \inputbwL_max.kr(1)),
			\inputbwR.kr.range(\inputbwR_min.kr(0), \inputbwR_max.kr(1))
		],
		\spread.kr.range(\spread_min.kr(0), \spread_max.kr(100)),
		/*drylevel:*/ 0,
		[\earlyreflevelL.kr.range(\earlyreflevelL_min.kr(0.1), \earlyreflevelL_max.kr(1)),
			\earlyreflevelR.kr.range(\earlyreflevelR_min.kr(0.1), \earlyreflevelR_max.kr(1))
		],
		[\taillevelL.kr.range(\taillevelL_min.kr(0.1), \taillevelL_max.kr(1)),
			\taillevelR.kr.range(\taillevelR_min.kr(0.1), \taillevelR_max.kr(1))
		],
		maxroomsize: 401
	);

	LeakDC.ar(sig);
},
specs: (

	revtimeL: [0.1, 1000, \lin, 0, 400],
	revtimeR: [0.1, 1000, \lin, 0, 400],

	dampingL: [0, 1, \lin, 0, 0.9],
	dampingR: [0, 1, \lin, 0, 0.9],

	inputbwL: [0, 1, \lin, 0, 0.75],
	inputbwR: [0, 1, \lin, 0, 0.75],

	spread: [0, 100, \lin, 0, 50],

	earlyreflevelL: [0.1, 1, \lin, 0, 0.07943282347242],
	earlyreflevelR: [0.1, 1, \lin, 0, 0.07943282347242],

	taillevelL: [0.1, 1, \lin, 0, 0.9],
	taillevelR: [0.1, 1, \lin, 0, 0.9]
)
)

