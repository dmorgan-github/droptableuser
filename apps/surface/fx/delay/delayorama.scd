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
		[\inputgainL.kr(0),
			\inputgainR.kr(0)
		],
		[\feedbackL.kr(30),
			\feedbackR.kr(30)
		],
		[\numtapsL.kr(1),
			\numtapsR.kr(1)
		],
		[\firstdelayL.kr(1),
			\firstdelayR.kr(1)
		],
		[\delayrangeL.kr(1),
			\delayrangeR.kr(1)
		],
		[\delaychangeL.kr(1),
			\delaychangeR.kr(1)
		],
		[\delayrandomL.kr(30),
			\delayrandomR.kr(30)
		],
		[\ampchangeL.kr(0.5),
			\ampchangeR.kr(0.5)
		],
		[\amprandL.kr(50),
			\amprandR.kr(50)
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
