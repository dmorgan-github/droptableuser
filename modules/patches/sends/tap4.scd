/////////////////////////////////////////
// send1
~p[\tap4].clear;
(~p[\tap4][0] = {

	var in = \in.ar([0,0]);

	var tap1, tap2, tap3, tap4;
	var fbNode = FbNode(1, 6.5, 4);

	var tap1_delay = \tap1_delay.kr(0.2).lag(0.1);
	var tap2_delay = \tap2_delay.kr(0.5).lag(0.1);
	var tap3_delay = \tap3_delay.kr(0.7).lag(0.1);
	var tap4_delay = \tap4_delay.kr(1).lag(0.1);

	var tap1_mul = \tap1_mul.kr(1).lag(0.1);
	var tap2_mul = \tap2_mul.kr(0.7).lag(0.1);
	var tap3_mul = \tap3_mul.kr(0.5).lag(0.1);
	var tap4_mul = \tap4_mul.kr(0.2).lag(0.1);

	tap1 = fbNode.delay(tap1_delay);
	tap2 = fbNode.delay(tap2_delay);
	tap3 = fbNode.delay(tap3_delay);
	tap4 = fbNode.delay(tap4_delay);

	fbNode.write(in.asArray.sum
		+ (tap1 * \tap1_fb.kr(0).lag(0.1))
		+ (tap2 * \tap2_fb.kr(0).lag(0.1))
		+ (tap3 * \tap3_fb.kr(0).lag(0.1))
		+ (tap4 * \tap4_fb.kr(0).lag(0.1))
	);

	Splay.ar([tap1 * tap1_mul, tap2 * tap2_mul, tap3 * tap3_mul, tap4 * tap4_mul],
		\spread.kr(1),
		center:\center.kr(0)
	);

});
~p[\tap4].play;
~p[\tap4].stop;
~p[\tap4].gui;



(~p[\tap4_2][0] = {

	var in = \in.ar([0,0]);

	var tap1, tap2, tap3, tap4;
	var fbNode = FbNode(1, 6.5, 4);

	var tap1_delay = \tap1_delay.kr(0.2).lag(0.1);
	var tap2_delay = \tap2_delay.kr(0.5).lag(0.1);
	var tap3_delay = \tap3_delay.kr(0.7).lag(0.1);
	var tap4_delay = \tap4_delay.kr(1).lag(0.1);

	var tap1_mul = \tap1_mul.kr(1).lag(0.1);
	var tap2_mul = \tap2_mul.kr(0.7).lag(0.1);
	var tap3_mul = \tap3_mul.kr(0.5).lag(0.1);
	var tap4_mul = \tap4_mul.kr(0.2).lag(0.1);

	tap1 = fbNode.delay(tap1_delay);
	tap2 = fbNode.delay(tap2_delay);
	tap3 = fbNode.delay(tap3_delay);
	tap4 = fbNode.delay(tap4_delay);

	fbNode.write(in.asArray.sum
		+ (tap1 * \tap1_fb.kr(0).lag(0.1))
		+ (tap2 * \tap2_fb.kr(0).lag(0.1))
		+ (tap3 * \tap3_fb.kr(0).lag(0.1))
		+ (tap4 * \tap4_fb.kr(0).lag(0.1))
	);

	Splay.ar([tap1 * tap1_mul, tap2 * tap2_mul, tap3 * tap3_mul, tap4 * tap4_mul],
		\spread.kr(1),
		center:\center.kr(0)
	);

});
~p[\tap4_2].play;
~p[\tap4_2].stop;
~p[\tap4_2].gui;

