(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var sig = Decimator.ar(in,
		rate: 44100/\rate.ar(1).clip(1,10),
		bits: \bits.ar(24)
	);

	Splay.ar(LeakDC.ar(sig), spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [
	\rate -> [1, 10, \lin, 0, 1],
	\bits -> [2, 24, \lin, 0, 24],
	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0],
]
)
