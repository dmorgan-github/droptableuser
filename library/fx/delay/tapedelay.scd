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

	Splay.ar(sig,
		spread:\spread.ar(1),
		center:\pan.ar(0)
    ) * \output.ar(1);
},
specs: [
    \tape_speed -> ControlSpec(0,10,\lin,0,1, units:"fx"),
	\tap1_distance -> ControlSpec(0,4,\lin,0,1, units:"fx"),
	\tap1_level -> ControlSpec(0,1,\lin,0,0, units:"fx"),
	\tap2_distance -> ControlSpec(0,4,\lin,0,2, units:"fx"),
	\tap2_level -> ControlSpec(0,1,\lin,0,0, units:"fx"),
	\tap3_distance -> ControlSpec(0,4,\lin,0,3, units:"fx"),
	\tap3_level -> ControlSpec(0,1,\lin,0,0, units:"fx"),
	\tap4_distance -> ControlSpec(0,4,\lin,0,4, units:"fx"),
	\tap4_level -> ControlSpec(0,1,\lin,0,0, units:"fx"),
	\ampL -> ControlSpec(0,4,\lin,0,1, units:"fx"),
	\ampR -> ControlSpec(0,4,\lin,0,1, units:"fx"),
	\spread -> ControlSpec(0,1,\lin,0, 1, units:"stereo"),
	\pan -> ControlSpec(-1,1,\lin,0,0, units:"stereo"),
    \input -> ControlSpec(0, 2, \lin, 0, 1, units:"vp;"),
    \output -> ControlSpec(0, 2, \lin, 0, 1, units: "vol")
]
)
