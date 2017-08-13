(
func: {arg in;
	FreeVerb.ar(in,
		[\mixL.kr.range(\mixL_min.kr(0), \mixL_max.kr(1)), \mixR.kr.range(\mixR_min.kr(0), \mixR_max.kr(1))],
		[\room.kr.range(\room_min.kr(0), \room_max.kr(1)), \roomR.kr.range(\roomR_min.kr(0), \roomR_max.kr(1))],
		[\damp.kr.range(\damp_min.kr(0), \damp_max.kr(1)), \dampR.kr.range(\dampR_min.kr(0), \dampR_max.kr(1))]
	);
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