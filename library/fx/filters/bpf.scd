(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var res = \res.kr(0).linlin(0, 1, 1.4, 0.0001);
	var sig = BPF.ar(in,
		freq:\freq.ar(1200).clip(20, 20000),
		rq:\res.kr(0).linlin(0, 1, 1.4, 0.0001),
		mul:res.reciprocal.sqrt
	);

	Splay.ar(sig,
		spread:\spread.ar(1),
		center:\center.ar(0)
	) * [\ampL.ar(0.dbamp), \ampR.ar(0.dbamp)];
},
specs: [
	\freq -> [20, 20000, \lin, 0, 1200],
	\res -> [0, 1, \lin, 0, 0],
	\ampL -> [0,4,\lin,0,1],
	\ampR -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)