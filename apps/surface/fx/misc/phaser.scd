(
func: {arg in;

	LADSPA.ar(1, 1217,
		\rate.kr(1),
		\depth.kr(0.5),
		\feedback.kr(0),
		\spread.kr(0.1),
		in
	);
},
specs: (
	rate: [0, 100, \lin, 0, 1],
	depth: [0, 1, \lin, 0, 0.5],
	feedback: [-1, 1, \lin, 0, 0],
	spread: [0, 2, \lin, 0, 0.1]
)
)