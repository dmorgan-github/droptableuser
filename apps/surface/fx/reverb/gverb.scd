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
		50,
		[\revtimeL.kr(3),
			\revtimeR.kr(3)
		],
		[\dampingL.kr(0.9),
			\dampingR.kr(0.9)
		],
		[\inputbwL.kr(0.75),
			\inputbwR.kr(0.75)
		],
		\spread.kr(50),
		/*drylevel:*/ 0,
		[\earlyreflevelL.kr(0.07943282347242),
			\earlyreflevelR.kr(0.07943282347242)
		],
		[\taillevelL.kr(0.5),
			\taillevelR.kr(0.5)
		],
		maxroomsize: 400
	);

	sig;
},
specs: (

	revtimeL: [0.1, 1000, \lin, 0, 3],
	revtimeR: [0.1, 1000, \lin, 0, 3],

	dampingL: [0, 1, \lin, 0, 0.9],
	dampingR: [0, 1, \lin, 0, 0.9],

	inputbwL: [0, 1, \lin, 0, 0.75],
	inputbwR: [0, 1, \lin, 0, 0.75],

	spread: [0, 100, \lin, 0, 50],

	earlyreflevelL: [0.1, 1, \lin, 0, 0.07943282347242],
	earlyreflevelR: [0.1, 1, \lin, 0, 0.07943282347242],

	taillevelL: [0.1, 1, \lin, 0, 0.5],
	taillevelR: [0.1, 1, \lin, 0, 0.5]
)
)

