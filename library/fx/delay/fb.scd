(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var fblevel = \fb.ar(0.3);
	var delL = \delL.ar(6).lag(0.1) * 16.reciprocal;
	var delR = \delR.ar(10).lag(0.1) * 16.reciprocal;
	var tempo = \tempo.ar(1).lag(0.1);
	var time = \time.ar(0).lag(0.1);
	var sig = FbC({arg fb; fb * fblevel + in}, 5, [delL, delR] * tempo + time);
	Splay.ar(sig, spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [
	\fb -> [0.0, 1, \lin, 0.0, 0.3],
	\delL -> [1, 16, \lin, 1, 6],
	\delR -> [1, 16, \lin, 1, 10],
	\tempo -> [0.001, 4, \lin, 0.0, 1],
	\time -> [0.0, 4, \lin, 0.0, 0],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0],
	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1]
]
)