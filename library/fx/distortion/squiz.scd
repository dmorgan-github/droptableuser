(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var sig = Squiz.ar(in,
		pitchratio: \pitchratio.ar(12).midiratio,
		zcperchunk: \zcperchunk.ar(1)
	);
	Splay.ar(LeakDC.ar(sig), spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [
	\pitchratio -> [1, 24, \lin, 1, 12],
	\zcperchunk -> [1, 100, \lin, 0, 1],
	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)