(
func: {arg in;

	var sig = LADSPA.ar(1, 1605,
		in,
		\delay.kr.range(\delay_min.kr(0), \delay_max.kr(5)).lag(0.1),
		-70,
		0,
		\feedback.kr.range(\feedback_min.kr(0), \feedback_max.kr(1)),
		\crossfade.kr.range(\crossfade_min.kr(0), \crossfade_max.kr(100))
	);

	LeakDC.ar(sig);
},
specs: (
	delay: [0, 5, \lin, 0, 1],
	//dry: [-70, 0, \lin, 0, 0.2],
	//wet: [-70, 0, \lin, 0, 0],
	feedback: [0, 1, \lin, 0, 0.5],
	crossfade: [0, 100, \lin, 0, 20]
)
)