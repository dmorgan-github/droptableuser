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
synth: {arg sig_in;

    var in = sig_in * \input.ar(1);
    var sig = LADSPA.ar(1, 1402,
        RandSeed.kr(1000.rand),
        \inputgain.ar(0).lag(0.001),
        \feedback.ar(30).lag(0.001),
        \numtaps.ar(1).lag(0.001),
        \firstdelay.ar(1).lag(0.001),
        \delayrange.ar(1).lag(0.001),
        \delaychange.ar(1).lag(0.001),
        \delayrandom.ar(30).lag(0.001),
        \ampchange.ar(0.5).lag(0.001),
        \amprand.ar(50).lag(0.001),
        /*dry/wet*/1,
        in
    );

    sig = LeakDC.ar(sig);
    Splay.ar(sig,
        spread:\spread.ar(1),
        center:\pan.ar(0)
    ) * \output.ar(1);
},
specs: [
    \inputgain -> ControlSpec(-96, 24, \lin, 0, 0, units:"fx"),
    \feedback -> ControlSpec(0, 100, \lin, 0, 30, units:"fx"),
    \numtaps -> ControlSpec(2, 128, \lin, 0, 1, units:"fx"),
    \firstdelay -> ControlSpec(0, 5, \lin, 0, 1, units:"fx"),
    \delayrange -> ControlSpec(0.0001, 6, \lin, 0, 1, units:"fx"),
    \delaychange -> ControlSpec(0.2, 5, \lin, 0, 1, units:"fx"),
    \delayrandom -> ControlSpec(0, 100, \lin, 0, 30, units:"fx"),
    \ampchange -> ControlSpec(0.2, 5, \lin, 0, 0.5, units:"fx"),
    \amprand -> ControlSpec(0, 100, \lin, 0, 50, units:"fx"),
    \spread -> ControlSpec(0,1,\lin,0, 1, units:"stereo"),
    \pan -> ControlSpec(-1,1,\lin,0,0, units:"stereo"),
    \input -> ControlSpec(0, 2, \lin, 0, 1, units:"vol"),
    \output -> ControlSpec(0, 2, \lin, 0, 1, units: "vol")
]
)
