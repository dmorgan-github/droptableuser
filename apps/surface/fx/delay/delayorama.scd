/*
2.31  Delayorama (delayorama, 1402)

Random seed

Controls the random numbers that will be used to stagger the delays and amplitudes if random is turned up on them. Changing this forces the random values to be recalulated.
Input gain (dB)

Controls the gain of the input signal in dB's.
Feedback (%)

Controls the amount of output signal fed back into the input.
Number of taps

Controls the number of taps in the delay.
First delay (s)

The time of the first delay.
Delay range (s)

The time difference between the first and last delay.
Delay change

The scaling factor between one delay and the next.
Delay random (%)

The random factor applied to the delay.
Amplitude change

The scaling factor between one amplitude and the next.
Amplitude random (%)

The random factor applied to the amplitude.
Dry/wet mix

The level of delayed sound mixed into the output.
*/


(
func: {arg in;

	var sig = LADSPA.ar(1, 1402,
		RandSeed.ir(1000),
		[\inputgainL.kr.range(\inputgainL_min.kr(-96), \inputgainL_max.kr(24)),
			\inputgainR.kr.range(\inputgainR_min.kr(-96), \inputgainR_max.kr(24))
		],
		[\feedbackL.kr.range(\feedbackL_min.kr(0), \feedbackL_max.kr(100)),
			\feedbackR.kr.range(\feedbackR_min.kr(0), \feedbackR_max.kr(100))
		],
		[\numtapsL.kr.range(\numtapsL_min.kr(2), \numtapsL_max.kr(128)).lag(0.1),
			\numtapsR.kr.range(\numtapsR_min.kr(2), \numtapsR_max.kr(128)).lag(0.1)
		],
		[\firstdelayL.kr.range(\firstdelayL_min.kr(0), \firstdelayL_max.kr(5)),
			\firstdelayR.kr.range(\firstdelayR_min.kr(0), \firstdelayR_max.kr(5))
		],
		[\delayrangeL.kr.range(\delayrangeL_min.kr(0.0001), \delayrangeL_max.kr(6)),
			\delayrangeR.kr.range(\delayrangeR_min.kr(0.0001), \delayrangeR_max.kr(6))
		],
		[\delaychangeL.kr.range(\delaychangeL_min.kr(0.2), \delaychangeL_max.kr(5)),
			\delaychangeR.kr.range(\delaychangeR_min.kr(0.2), \delaychangeR_max.kr(5))
		],
		[\delayrandomL.kr.range(\delayrandomL_min.kr(0), \delayrandomL_max.kr(100)),
			\delayrandomR.kr.range(\delayrandomR_min.kr(0), \delayrandomR_max.kr(100))
		],
		[\ampchangeL.kr.range(\ampchangeL_min.kr(0.2), \ampchangeL_max.kr(5)),
			\ampchangeR.kr.range(\ampchangeR_min.kr(0.2), \ampchangeR_max.kr(5))
		],
		[\amprandL.kr.range(\amprandL_min.kr(0), \amprandL_max.kr(100)),
			\amprandR.kr.range(\amprandR_min.kr(0), \amprandR_max.kr(100))
		],
		/*dry/wet*/1,
		in
	);

	LeakDC.ar(sig);
},
specs: (
	inputgainL: [-96, 24, \lin, 0, 0],
	inputgainR: [-96, 24, \lin, 0, 0],

	feedbackL: [0, 100, \lin, 0, 30],
	feedbackR: [0, 100, \lin, 0, 30],

	numtapsL: [2, 128, \lin, 0, 1],
	numtapsR: [2, 128, \lin, 0, 1],

	firstdelayL: [0, 5, \lin, 0, 1],
	firstdelayR: [0, 5, \lin, 0, 1],

	delayrangeL: [0.0001, 6, \lin, 0, 1],
	delayrangeR: [0.0001, 6, \lin, 0, 1],

	delaychangeL: [0.2, 5, \lin, 0, 1],
	delaychangeR: [0.2, 5, \lin, 0, 1],

	delayrandomL: [0, 100, \lin, 0, 30],
	delayrandomR: [0, 100, \lin, 0, 30],

	ampchangeL: [0.2, 5, \lin, 0, 0.5],
	ampchangeR: [0.2, 5, \lin, 0, 0.5],

	amprandL: [0, 100, \lin, 0, 50],
	amprandR: [0, 100, \lin, 0, 50]
)
)
