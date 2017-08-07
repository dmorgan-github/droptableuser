(
func: {arg in;
	FreeVerb.ar(in,
		\mix.kr.range(\mix_min.kr(0), \mix_max.kr(1)),
		\room.kr.range(\room_min.kr(0), \room_max.kr(1)),
		\damp.kr.range(\damp_min.kr(0), \damp_max.kr(1))
	);
},
specs: (
	mix: [0, 1, \lin, 0, 0.33],
	room: [0, 1, \lin, 0, 0.5],
	damp: [0, 1, \lin, 0, 0.5]
)
)