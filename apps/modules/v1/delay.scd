(
~greyhole = {arg chans = 1, delay = 2, damp = 0, size = 1, diff = 0.707, fb = 0.7, modDepth = 0.1, modFreq = 2, lr = false;

	{
		var in = \in.ar(0.dup(chans));
		var fx = if (lr) {

			Greyhole.ar(in,
				[\delayL.kr(delay),\delayR.kr(delay)],
				[\dampL.kr(damp),\dampR.kr(damp)],
				[\sizeL.kr(size),\sizeR.kr(size)],
				[\diffL.kr(diff),\diffR.kr(diff)],
				[\fbL.kr(fb),\fbR.kr(fb)],
				[\modDepthL.kr(modDepth),\modDepthR.kr(modDepth)],
				[\modFreqL.kr(modFreq),\modFreqR.kr(modFreq)]
			);
		} {

			Greyhole.ar(in,
				\delay.kr(delay),
				\damp.kr(damp),
				\size.kr(size),
				\diff.kr(diff),
				\fb.kr(fb),
				\modDepth.kr(modDepth),
				\modFreq.kr(modFreq)
			);
		};
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	};
};

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
		var fx = if (lr) {
			LADSPA.ar(1, 1402,
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
		} {
			LADSPA.ar(1, 1402,
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
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	};
};

~rnd_delay = {arg chans = 1, rate = 13, lr = false;

	{
		var in = \in.ar(0.dup(chans));
		var fx = if (lr) {
			DelayC.ar(in, 1.0, LFNoise0.ar([\rateL.kr(rate),\rateR.kr(rate)]).range(0.0, 1.0))
		} {
			DelayC.ar(in, 1.0, LFNoise0.ar(\rate.kr(rate)).range(0.0, 1.0))
		};
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	};
};

~feedback = {arg chans = 1, tempo = 1, decay = 0.3, delay = 0.375;

	{
		var in = \in.ar(0.dup(chans));
		var tempo_in = \tempo.kr(tempo);
		var decay_in = \decay.kr(decay);
		var delay_in = \delay.kr(delay);
		var fx = FbC({arg fb; fb * decay_in + in}, tempo_in * delay_in);
		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	};
};

~comb_long = {arg chans = 1, maxdelay = 8, num = 4;

	{
		var in = \in.ar(0.dup(chans));
		var del = in;
		var fx = (0..num-1).collect({arg num;
			var fb = NamedControl.kr(('fb_' ++ num).asSymbol, 1);
			del = CombC.ar(in, maxdelay, LFNoise2.kr(0.01).range(1, maxdelay), fb);
			del;
		});

		var wet = \wet.kr(1);
		XFade2.ar(in, fx, wet.linlin(0,1,-1,1));
	}
};

)