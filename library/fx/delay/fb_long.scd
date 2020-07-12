(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var fblevel = \fb.ar(0.7);
	var delL = \delL.ar(6).lag(0.1);
	var delR = \delR.ar(10).lag(0.1);
	var tempo = \tempo.ar(1).lag(0.1);
	var sig = FbC({arg fb; fb * fblevel + in}, 16, [delL, delR] * tempo);
	Splay.ar(sig,
		spread:\spread.ar(1),
		center:\center.ar(0)
	) * [\ampL.ar(0.dbamp), \ampR.ar(0.dbamp)];
},
specs: [
	\fb -> [0.0, 1, \lin, 0.0, 0.7],
	\delL -> [1, 16, \lin, 1, 6],
	\delR -> [1, 16, \lin, 1, 10],
	\tempo -> [0.001, 4, \lin, 0.0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0],
	\ampL -> [0,4,\lin,0,1],
	\ampR -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1]
]
)