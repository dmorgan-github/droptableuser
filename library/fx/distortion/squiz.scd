(
synth: {arg sig_in;

    var in = sig_in * \squiz_input.ar(1);
    var sig = Squiz.ar(in,
        pitchratio: \pitchratio.ar(12).midiratio,
        zcperchunk: \zcperchunk.ar(1)
    );
    sig = LeakDC.ar(sig);
    sig = sig * \squiz_output.ar(1);
    sig;
},
specs: [
    pitchratio: ControlSpec(1, 24, \lin, 1, 12, "squiz"),
    zcperchunk: ControlSpec(1, 100, \lin, 0, 1, "squiz"),
    squiz_input: ControlSpec(0, 2, \lin, 0, 1, "vol"),
    squiz_output: ControlSpec(0, 2, \lin, 0, 1, units: "vol")
]
)