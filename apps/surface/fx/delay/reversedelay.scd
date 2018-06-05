(
func: {arg in;

	var sig = LADSPA.ar(1, 1605,
		in,
		\delay.kr(1),
		-70,
		0,
		\feedback.kr(0.5),
		\crossfade.kr(20)
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