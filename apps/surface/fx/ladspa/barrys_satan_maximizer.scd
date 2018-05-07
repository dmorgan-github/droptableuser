/*
# 1408 Barry's Satan Maximiser
> k: Decay time (samples) (2 to 30)
> k: Knee point (dB) (-90 to 0)
> a: Input
< a: Output
*/
(
func: {arg in;

	var sig = LADSPA.ar(1, 1408,
		[\decayL.kr(10), \decayR.kr(10)],
		[\kneepointL.kr(-10), \kneepointR.kr(-10)],
		in
	);

	LeakDC.ar(sig) * 0.1
},
specs: (
	decayL: [2, 30, \lin, 0, 10],
	decayR: [2, 30, \lin, 0, 10],

	kneepointL: [-90, 1, \lin, 0, -10],
	kneepointR: [-90, 1, \lin, 0, -10]
)
)