(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var sig = LADSPA.ar(1, 1605,
		in,
		[\delayL.ar(1).lag(0.1), \delayR.ar(1).lag(0.1)],
		-60, // dry
		0, // wet
		[\feedbackL.ar(0.5).lag(0.1), \feedbackR.ar(0.5).lag(0.1)],
		\crossfade.ar(20)
	);

	Splay.ar(sig,
		spread:\spread.ar(0.5),
		center:\center.ar(0)
	) * [\ampL.ar(0.dbamp), \ampR.ar(0.dbamp)];
},
specs: [
	\delayL -> [0, 5, \lin, 0, 1],
	\delayR -> [0, 5, \lin, 0, 1],
	\feedbackL -> [0, 1, \lin, 0, 0.5],
	\feedbackR -> [0, 1, \lin, 0, 0.5],
	\crossfade -> [0, 100, \lin, 0, 20],
	\ampL -> [0,4,\lin,0,1],
	\ampR -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 0.5],
	\center -> [-1,1,\lin,0,0],
]
)