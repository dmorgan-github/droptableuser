(
func: {arg in;

	LADSPA.ar(1, 1201,
		2, //\numvoices.kr.range(\numvoices_min.kr(1), \numvoices_max.kr(8)).lag(0.1),
		\delay.kr.range(\delay_min.kr(10), \delay_max.kr(40)),
		\voice.kr.range(\voice_min.kr(0), \voice_max.kr(2)),
		\detune.kr.range(\detune_min.kr(0), \detune_max.kr(5)),
		\lfo.kr.range(\lfo_min.kr(2), \lfo_max.kr(30)),
		\output.kr.range(\output_min.kr(-20), \output_max.kr(0)),
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
