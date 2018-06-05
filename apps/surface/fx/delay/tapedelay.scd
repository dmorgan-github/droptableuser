(
func: {arg in;

	var input = Mix.ar(in);
	var sig = LADSPA.ar(1, 1211,

		\tape_speed.kr(1),
		\dry.kr(0).ampdb,

		\tap1_distance.kr(1),
		\tap1_level.kr(0).ampdb,

		\tap2_distance.kr(2),
		\tap2_level.kr(0).ampdb,

		\tap3_distance.kr(3),
		\tap3_level.kr(0).ampdb,

		\tap4_distance.kr(4),
		\tap4_level.kr(0).ampdb,

		input
	);

	Pan2.ar(sig, 0);
},
specs: (
	tape_speed: [0,10,\lin,0,1],
	dry: [0,1,\lin,0,0],
	tap1_distance: [0,4,\lin,0,1],
	tap1_level: [0,1,\lin,0,0],
	tap2_distance: [0,4,\lin,0,2],
	tap2_level: [0,1,\lin,0,0],
	tap3_distance: [0,4,\lin,0,3],
	tap3_level: [0,1,\lin,0,0],
	tap4_distance: [0,4,\lin,0,4],
	tap4_level: [0,1,\lin,0,0]
)
)
