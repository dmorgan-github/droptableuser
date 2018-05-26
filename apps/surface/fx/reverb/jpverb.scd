(
func: {arg in;

	var sig = JPverb.ar(in,
		t60: [\t60L.kr(1), \t60R.kr(1)],
		damp: \damp.kr(0),
		size: [\sizeL.kr(1), \sizeR.kr(1)],
		earlyDiff: \earlyDiff.kr(0.707),
		modDepth: \modDepth.kr,
		modFreq: \modFreq.kr(1),
		low: \low.kr(1),
		mid: \mid.kr(1),
		high: \high.kr(1),
		lowcut: \lowcut.kr(500),
		highcut: \highcut.kr(2000)
	);

	Splay.ar(sig, spread:\spread.kr(1), center:\center.kr(0));
},
specs: (
	t60L: [0.1, 60, \lin, 0.0, 1],
	t60R: [0.1, 60, \lin, 0.0, 1],
	damp: [0, 1, \lin, 0.0, 0],
	sizeL: [0.5, 5, \lin, 0, 1],
	sizeR: [0.5, 5, \lin, 0, 1],
	earlyDiff: [0, 1, \lin, 0, 0.707],
	modDepth: [0, 1, \lin, 0, 0.1],
	modFreq: [0, 10, \lin, 0, 2],
	low: [0, 1, \lin, 0, 1],
	mid: [0, 1, \lin, 0, 1],
	high: [0, 1, \lin, 0, 1],
	lowcut: [100, 6000, \exp, 1, 500],
	highcut: [1000, 10000, \exp, 1, 2000],
	spread: [0, 1, \lin, 0, 1],
	center: [-1, 1, \lin, 0, 0]
)
)