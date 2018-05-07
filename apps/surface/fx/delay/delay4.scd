(
func: {arg in;

	var dt1 = \dt1.kr(0.2);
	var dt2 = \dt2.kr(0.2);
	var dt3 = \dt3.kr(0.2);
	var dt4 = \dt4.kr(0.2);

	var delay1 = DelayC.ar(in, dt1, dt1, \mix1.kr(0.25));
	var delay2 = DelayC.ar(in, dt2, dt2, \mix2.kr(0.25));
	var delay3 = DelayC.ar(in, dt3, dt3, \mix3.kr(0.25));
	var delay4 = DelayC.ar(in, dt4, dt4, \mix4.kr(0.25));

	delay1 + delay2 + delay3 + delay4;
},

specs: (
	dt1: [0.001, 360, \lin, 0, 0.2],
	dt2: [0.001, 360, \lin, 0, 0.2],
	dt3: [0.001, 360, \lin, 0, 0.2],
	dt4: [0.001, 360, \lin, 0, 0.2],

	mix1: [0.001, 1, \lin, 0, 0.25],
	mix2: [0.001, 1, \lin, 0, 0.25],
	mix3: [0.001, 1, \lin, 0, 0.25],
	mix4: [0.001, 1, \lin, 0, 0.25]
)
)