(
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
~delayorama = {arg chans = 2, lr = false;
	{
		var in = \in.ar(0.dup(chans));
		LADSPA.ar(chans, 1402,
			RandSeed.ir(1000),
			\inputgain.kr(0),
			\feedback.kr(30),
			\numtaps.kr(1),
			\firstdelay.kr(1),
			\delayrange.kr(1),
			\delaychange.kr(1),
			\delayrandom.kr(30),
			\ampchange.kr(0.5),
			\amprand.kr(50),
			/*dry/wet*/1,
			in
		);
	};
};

/*
# 1605 Reverse Delay (5s max)
> a: Input
< a: Output
> k: Delay Time (s) (0 to 5)
> k: Dry Level (dB) (-70 to 0)
> k: Wet Level (dB) (-70 to 0)
> k: Feedback (0 to 1)
> k: Crossfade samples (0 to 5000)
*/
~reversedelay = {arg chans = 1, delay = 1, fb = 0.5, crossfade = 250;

	{
		var in = \in.ar(0.dup(chans));
		var fx = LADSPA.ar(1, 1605,
			in,
			\delay.kr(delay),
			-70.dbamp,
			0.dbamp,
			\fb.kr(fb),
			\crossfade.kr(crossfade)
		);
		fx;
	};
};

)