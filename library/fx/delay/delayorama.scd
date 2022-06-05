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
synth: {arg in;

    var sig = LADSPA.ar(2, 1402,
        RandSeed.kr(1000.rand),
        \inputgain.ar(0, spec: ControlSpec(-96, 24, \lin, 0, 0, units:"delayoram")).lag(0.001),
        \feedback.ar(30, spec: ControlSpec(0, 100, \lin, 0, 30, units:"delayoram")).lag(0.001),
        \numtaps.ar(1, spec: ControlSpec(2, 128, \lin, 1, 1, units:"delayoram")).lag(0.001),
        \firstdelay.ar(1, spec: ControlSpec(0, 5, \lin, 0, 1, units:"delayoram")).lag(0.001),
        \delayrange.ar(1, spec: ControlSpec(0.0001, 6, \lin, 0, 1, units:"delayoram")).lag(0.001),
        \delaychange.ar(1, spec: ControlSpec(0.2, 5, \lin, 0, 1, units:"delayoram")).lag(0.001),
        \delayrandom.ar(30, spec: ControlSpec(0, 100, \lin, 0, 30, units:"delayoram")).lag(0.001),
        \ampchange.ar(0.5, spec: ControlSpec(0.2, 5, \lin, 0, 0.5, units:"delayoram")).lag(0.001),
        \amprand.ar(50, spec: ControlSpec(0, 100, \lin, 0, 50, units:"delayoram")).lag(0.001),
        /*dry/wet*/1,
        in
    );

    sig = LeakDC.ar(sig);
    sig = in.blend(sig, \delayorama_mix.kr(0.5, spec: ControlSpec(0, 1, \lin, 0.4, "delayoram")));
    sig;
}
)
