/*
# 1408 Barry's Satan Maximiser
> k: Decay time (samples) (2 to 30)
> k: Knee point (dB) (-90 to 0)
> a: Input
< a: Output
*/
(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var sig = LADSPA.ar(1, 1408,
		\decay.ar(10),
		[
			\kneepointL.ar(-10),
			\kneepointR.ar(-10)
		],
		in
	);

	sig = LeakDC.ar(sig) * 0.1;
	Splay.ar(sig, spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [
	\decay -> [2, 30, \lin, 0, 10],
	\kneepointL -> [-90, 1, \lin, 0, -30],
	\kneepointR -> [-90, 1, \lin, 0, -30],
	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)