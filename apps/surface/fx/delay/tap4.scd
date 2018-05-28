(
func: {arg in;

	/*

	var buf = LocalBuf(s.sampleRate * 6.5, 1).clear;//\buf.kr(0);

	var tapPhase, tap1, tap2, tap3, tap4;

	var tap1_delay = \tap1_delay.kr(0.1);
	var tap2_delay = \tap2_delay.kr(0.1);
	var tap3_delay = \tap3_delay.kr(0.1);
	var tap4_delay = \tap4_delay.kr(0.1);

	var tap1_mul = \tap1_mul.kr(1);
	var tap2_mul = \tap2_mul.kr(1);
	var tap3_mul = \tap3_mul.kr(1);
	var tap4_mul = \tap4_mul.kr(1);

	tapPhase = DelTapWr.ar(buf, Mix.ar(in));

    #tap1, tap2, tap3, tap4 = DelTapRd.ar(buf, tapPhase,
        [tap1_delay, tap2_delay, tap3_delay, tap4_delay],
        4,
        [tap1_mul, tap2_mul, tap3_mul, tap4_mul]
    );

	*/

	var tap1, tap2, tap3, tap4;
	var fbNode = FbNode(1, 6.5, 4);

	var tap1_delay = \tap1_delay.kr(0.1).lag(0.1);
	var tap2_delay = \tap2_delay.kr(0.1).lag(0.1);
	var tap3_delay = \tap3_delay.kr(0.1).lag(0.1);
	var tap4_delay = \tap4_delay.kr(0.1).lag(0.1);

	var tap1_mul = \tap1_mul.kr(1).lag(0.1);
	var tap2_mul = \tap2_mul.kr(1).lag(0.1);
	var tap3_mul = \tap3_mul.kr(1).lag(0.1);
	var tap4_mul = \tap4_mul.kr(1).lag(0.1);

	tap1 = fbNode.delay(tap1_delay);
	tap2 = fbNode.delay(tap2_delay);
	tap3 = fbNode.delay(tap3_delay);
	tap4 = fbNode.delay(tap4_delay);

	fbNode.write(Mix.ar(in)
		+ (tap1 * \tap1_fb.kr(0).lag(0.1))
		+ (tap2 * \tap2_fb.kr(0).lag(0.1))
		+ (tap3 * \tap3_fb.kr(0).lag(0.1))
		+ (tap4 * \tap4_fb.kr(0).lag(0.1))
	);

	Splay.ar([tap1 * tap1_mul, tap2 * tap2_mul, tap3 * tap3_mul, tap4 * tap4_mul],
		\spread.kr(1),
		center:\center.kr(0)
	);
},
specs: (

	tap1_delay: [0, 6, \lin, 0, 0.2],
	tap2_delay: [0, 6, \lin, 0, 0.5],
	tap3_delay: [0, 6, \lin, 0, 0.7],
	tap4_delay: [0, 6, \lin, 0, 1],

	tap1_mul: [0, 1, \lin, 0, 1],
	tap2_mul: [0, 1, \lin, 0, 0.7],
	tap3_mul: [0, 1, \lin, 0, 0.5],
	tap4_mul: [0, 1, \lin, 0, 0.2],

	tap1_fb: [0, 1, \lin, 0, 0],
	tap2_fb: [0, 1, \lin, 0, 0],
	tap3_fb: [0, 1, \lin, 0, 0],
	tap4_fb: [0, 1, \lin, 0, 0],

	spread: [0, 1, \lin, 0, 1],
	center: [-1, 1, \lin, 0, 0]
)
)