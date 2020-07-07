(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var sig = Disintegrator.ar(in,
		probability:\prob.ar(0.5),
		multiplier:\mult.ar(0)
	);
	Splay.ar(LeakDC.ar(sig), spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [
	\prob -> [0, 1, \lin, 0, 0.5],
	\mult -> [-1, 1, \lin, 0, 0],
	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)