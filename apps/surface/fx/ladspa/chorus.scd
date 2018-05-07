(
func: {arg in;

	LADSPA.ar(1, 1201,
		2, //\numvoices.kr.range(\numvoices_min.kr(1), \numvoices_max.kr(8)).lag(0.1),
		\delay.kr(10),
		\voice.kr(0),
		\detune.kr(0.1),
		\lfo.kr(2),
		\output.kr(0),
		in
	);
},
specs: (
	//\numvoices: [1, 8, \lin, 0, 2],
	\delay: [10, 40, \lin, 0, 10],
	\voice: [0, 2, \lin, 0, 0],
	\detune: [0, 5, \lin, 0, 0.1],
	\lfo: [2, 30, \lin, 0, 2],
	\output: [-20, 0, \lin, 0, 0]
)
)
