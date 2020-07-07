(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var tap1, tap2, tap3, tap4;
	var fbNode = FbNode(1, 6.5, 4);

	var tap1_delay = \tap1_delay.ar(2).lag(0.1)/16;
	var tap2_delay = \tap2_delay.ar(6).lag(0.1)/16;
	var tap3_delay = \tap3_delay.ar(10).lag(0.1)/16;
	var tap4_delay = \tap4_delay.ar(16).lag(0.1)/16;

	var tap1_mul = \tap1_mul.ar(1).lag(0.1);
	var tap2_mul = \tap2_mul.ar(0.7).lag(0.1);
	var tap3_mul = \tap3_mul.ar(0.5).lag(0.1);
	var tap4_mul = \tap4_mul.ar(0.2).lag(0.1);

	tap1 = fbNode.delay(tap1_delay);
	tap2 = fbNode.delay(tap2_delay);
	tap3 = fbNode.delay(tap3_delay);
	tap4 = fbNode.delay(tap4_delay);

	fbNode.write(Mix.ar(in)
		+ (tap1 * \tap1_fb.ar(0).lag(0.1))
		+ (tap2 * \tap2_fb.ar(0).lag(0.1))
		+ (tap3 * \tap3_fb.ar(0).lag(0.1))
		+ (tap4 * \tap4_fb.ar(0).lag(0.1))
	);

	Splay.ar([tap1 * tap1_mul, tap2 * tap2_mul, tap3 * tap3_mul, tap4 * tap4_mul],
		\spread.ar(1),
		center:\center.ar(0)
	) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [

	\tap1_delay -> [1, 32, \lin, 1, 2],
	\tap2_delay -> [1, 32, \lin, 1, 6],
	\tap3_delay -> [1, 32, \lin, 1, 10],
	\tap4_delay -> [1, 32, \lin, 1, 16],

	\tap1_mul -> [0, 1, \lin, 0, 1],
	\tap2_mul -> [0, 1, \lin, 0, 0.7],
	\tap3_mul -> [0, 1, \lin, 0, 0.5],
	\tap4_mul -> [0, 1, \lin, 0, 0.2],

	\tap1_fb -> [0, 1, \lin, 0, 0],
	\tap2_fb -> [0, 1, \lin, 0, 0],
	\tap3_fb -> [0, 1, \lin, 0, 0],
	\tap4_fb -> [0, 1, \lin, 0, 0],

	\spread -> [0, 1, \lin, 0, 1],
	\center -> [-1, 1, \lin, 0, 0],
	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1]
]
)