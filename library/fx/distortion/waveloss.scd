(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var sig = WaveLoss.ar(in,
		\drop.ar(20),
		\outof.ar(40),
		\mode.ar(1),
	);
	Splay.ar(LeakDC.ar(sig), spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [
	\drop -> [1,50,\lin,1,20],
	\outof -> [1,100,\lin,1,40],
	\mode -> [1,2,\lin,1,1],
	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)