(
func: {arg in;

	var sig = PitchShift.ar(in,
		0.1,
		\pitchRatio.kr(1),
		\pitchDispersion.kr(0),
		\timeDispersion.kr(0)
	);

	Splay.ar(sig);
},
specs: (
	pitchRatio: [0.0, 4.0, \lin, 0.0, 1],
	pitchDispersion: [0, 1, \lin, 0.0, 0.1],
	timeDispersion: [0.0, 0.1, \lin, 0, 0.1]
)
)