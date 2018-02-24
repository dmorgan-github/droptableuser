Barrys {
	/*
	# 1408 Barry's Satan Maximiser
	> k: Decay time (samples) (2 to 30)
	> k: Knee point (dB) (-90 to 0)
	> a: Input
	< a: Output
	*/
	*ar {arg in, nChans = 1, decay = 25, kneepoint = -50;

		^LADSPA.ar(nChans, 1408,
			decay,
			kneepoint,
			in
		);
	}
}

Delayorama {

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

	*ar {arg in, nChans = 1, inputgain = 0, feedback = 30, numtaps = 1, firstdelay = 1,
		delayrange = 1, delaychange = 1, delayrandom = 30, ampchange = 0.5, amprand = 50, wet = 1;

		^LADSPA.ar(nChans, 1402,
			RandSeed.ir(1000),
			inputgain,
			feedback,
			numtaps,
			firstdelay,
			delayrange,
			delaychange,
			delayrandom,
			ampchange,
			amprand,
			wet,
			in
		);
	}
}

