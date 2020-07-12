/*
# 1196 Fast overdrive
> k: Drive level (1 to 3)
> a: Input
< a: Output
*/
(
synth: {arg sig_in;
	var in = sig_in * \input.ar(1);
	var sig = LADSPA.ar(1, 1196,
		[
			\overdriveL.ar(1),
			\overdriveR.ar(1)
		],
		in
	);

	sig = LeakDC.ar(sig);
	Splay.ar(sig,
		spread:\spread.ar(1),
		center:\center.ar(0)
	) * [\ampL.ar(0.dbamp), \ampR.ar(0.dbamp)];
},
specs: [
	\decay -> [2, 30, \lin, 0, 10],
	\overdriveL -> [1, 3, \lin, 0, 1],
	\overdriveR -> [1, 3, \lin, 0, 1],
	\ampL -> [0,4,\lin,0,1],
	\ampR -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)