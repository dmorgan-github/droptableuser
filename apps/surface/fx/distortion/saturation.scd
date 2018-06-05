(
func: {arg in;
	var gain = \gain.kr(1);
	var sig = (in * gain).tanh * (gain.reciprocal.sqrt);
	//sig = DelayC.ar(sig, 0.1, Rand(3.5/1000, 65/1000));
	LeakDC.ar(sig);
	//sig;
},
specs: (
	gain: [1, 20, \lin, 0, 1]
)
)