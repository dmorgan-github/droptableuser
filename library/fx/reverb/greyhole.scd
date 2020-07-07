(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var sig = Greyhole.ar(in,
		\delayTime.ar(2),
		\damp.ar(0),
		\size.ar(1),
		\diff.ar(0.707),
		\feedback.ar(0.9),
		\modDepth.ar(0.1),
		\modFreq.ar(2)
	);

	Splay.ar(sig, spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [
	\delayTime -> [0.1, 60, \lin, 0, 2],
	\damp -> [0, 1, \lin, 0, 0],
	\size -> [0.5, 5, \lin, 0, 1],
	\diff -> [0,1, \lin, 0, 0.707],
	\feedback -> [0,1, \lin,0, 0.9],
	\modDepth -> [0, 1, \lin, 0, 0.1],
	\modFreq -> [0, 10, \lin, 0, 2],
	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)