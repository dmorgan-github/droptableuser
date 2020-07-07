(
synth: {arg sig_in;
	var in = sig_in * \input.ar(1);
	var delL = \del.ar(0.2).lag(0.1);
	var tempo = \tempo.ar(1).lag(0.1);
	var time = \time.ar(0).lag(0.1);
	var decay = \decay.ar(1).lag(0.1);
	var sig = AllpassC.ar(in, 4, delL * tempo + time, decay);
	Splay.ar(sig, spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [
	\decay -> [1, 16, \lin, 0, 1],
	\del -> [0.001, 1.0, \lin, 0, 0.2],
	\tempo -> [0.001, 4, \lin, 0.0, 1],
	\time -> [0.0, 4, \lin, 0.0, 0],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0],
	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1]
]
)