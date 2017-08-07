(
func: {arg in;

	var dt1 = \dt1.kr.range(\dt1_min.kr(0.001), \dt1_max.kr(360)).lag(0.1);
	var dt2 = \dt2.kr.range(\dt2_min.kr(0.001), \dt2_max.kr(360)).lag(0.1);
	var dt3 = \dt3.kr.range(\dt3_min.kr(0.001), \dt3_max.kr(360)).lag(0.1);
	var dt4 = \dt4.kr.range(\dt4_min.kr(0.001), \dt4_max.kr(360)).lag(0.1);

	var delay1 = DelayC.ar(in, dt1, dt1);
	var delay2 = DelayC.ar(in, dt2, dt2);
	var delay3 = DelayC.ar(in, dt3, dt3);
	var delay4 = DelayC.ar(in, dt4, dt4);
	delay1 + delay2 + delay3 + delay4;
},

specs: (
	dt1: [0.001, 360, \lin, 0, 0.2],
	dt2: [0.001, 360, \lin, 0, 0.2],
	dt3: [0.001, 360, \lin, 0, 0.2],
	dt4: [0.001, 360, \lin, 0, 0.2]
)
)