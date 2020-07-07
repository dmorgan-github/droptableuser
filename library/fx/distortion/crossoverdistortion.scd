(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var sig = CrossoverDistortion.ar(in,
		amp: \crossover.ar(0.5),
		smooth: \smooth.ar(0.5)
	);

	Splay.ar(LeakDC.ar(sig) * 0.1, spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [
	\crossover -> [0, 1, \lin, 0, 0.5],
	\smooth -> [0, 1, \lin, 0, 0.5],
	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0],
]
)