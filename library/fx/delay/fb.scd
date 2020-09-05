(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var fblevel = [\fbL.ar(0.3), \fbR.kr(0.5)];
	var delL = \delL.ar(6).lag(0.1) * 16.reciprocal;
	var delR = \delR.ar(10).lag(0.1) * 16.reciprocal;
	var tempo = \tempo.ar(1).lag(0.1);
	var time = \offset.ar(0).lag(0.1);

	var sig = HPF.ar(in, \hpf.kr(80));
	sig = FbC({arg fb; fb.reverse * fblevel + sig}, 5, [delL, delR] * tempo + time);

	sig = Splay.ar(sig, \spread.kr(0.5), 1, center:\center.kr(0));
	sig * [\ampL.ar(0.dbamp), \ampR.ar(0.dbamp)];
},
specs: [
	\fbL -> [0.0, 1, \lin, 0.0, 0.3],
	\fbR -> [0.0, 1, \lin, 0.0, 0.5],
	\delL -> [1, 16, \lin, 1, 6],
	\delR -> [1, 16, \lin, 1, 10],
	\hpf -> [20, 10000, \lin, 0, 80],
	\tempo -> [0.001, 4, \lin, 0.0, 1],
	\offset -> [0.0, 4, \lin, 0.0, 0],
	\center -> [-1, 1, \lin, 0, 0],
	\spread -> [0, 1, \lin, 0, 0.5],
	\ampL -> [0,4,\lin,0,1],
	\ampR -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1]
]
)