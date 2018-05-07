(
func: {arg in;

	var sig = FreeVerb.ar(in,
		[\mixL.kr(0.33), \mixR.kr(0.33)],
		[\room.kr(0.5), \roomR.kr(0.5)],
		[\damp.kr(0.5), \dampR.kr(0.5)]
	);

	sig;
},
specs: (
	mixL: [0, 1, \lin, 0, 0.33],
	mixR: [0, 1, \lin, 0, 0.33],
	roomL: [0, 1, \lin, 0, 0.5],
	roomR: [0, 1, \lin, 0, 0.5],
	dampL: [0, 1, \lin, 0, 0.5],
	dampR: [0, 1, \lin, 0, 0.5]
)
)