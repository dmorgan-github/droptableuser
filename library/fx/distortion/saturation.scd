(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var gain = [\gainL.ar(1), \gainR.ar(1)];
	var sig = (in * gain).tanh * (gain.reciprocal.sqrt);
	sig = LeakDC.ar(sig);
	Splay.ar(sig,
		spread:\spread.ar(1),
		center:\center.ar(0)
	) * [\ampL.ar(0.dbamp), \ampR.ar(0.dbamp)];
},
specs: [
	\gainL -> [1, 200, \lin, 0, 1],
	\gainR -> [1, 200, \lin, 0, 1],
	\ampL -> [0,4,\lin,0,1],
	\ampR -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)