(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var input = Mix.ar(in);
	var sig = LADSPA.ar(1, 1211,

		\tape_speed.ar(1),
		0.ampdb, //-70

		\tap1_distance.ar(1),
		\tap1_level.ar(0).ampdb,

		\tap2_distance.ar(2),
		\tap2_level.ar(0).ampdb,

		\tap3_distance.ar(3),
		\tap3_level.ar(0).ampdb,

		\tap4_distance.ar(4),
		\tap4_level.ar(0).ampdb,

		input
	);

	Splay.ar(sig, spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [
	\tape_speed -> [0,10,\lin,0,1],
	\tap1_distance -> [0,4,\lin,0,1],
	\tap1_level -> [0,1,\lin,0,0],
	\tap2_distance -> [0,4,\lin,0,2],
	\tap2_level -> [0,1,\lin,0,0],
	\tap3_distance -> [0,4,\lin,0,3],
	\tap3_level -> [0,1,\lin,0,0],
	\tap4_distance -> [0,4,\lin,0,4],
	\tap4_level -> [0,1,\lin,0,0],
	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0],
]
)
