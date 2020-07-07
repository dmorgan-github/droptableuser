(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var gain = \gain.ar(1);
	var sig = (in * gain).fold(-1, 1) * (gain.reciprocal.sqrt);
	Splay.ar(LeakDC.ar(sig), spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [
	\gain -> [1, 20, \lin, 0, 1],
	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)