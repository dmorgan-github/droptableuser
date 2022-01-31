(
synth: {arg sig_in;

    var in = sig_in * \decimator_input.ar(1);
    var sig = Decimator.ar(in,
        rate: \samplerate.ar(41000),
        bits: \bits.ar(24)
    );

    sig = LeakDC.ar(sig);
    sig = in.blend(sig, \decimator_mix.kr(1));
    sig * \decimator_output.ar(1);
},
specs: [
    samplerate: ControlSpec(512, 41000, \lin, 0, 41000, units:"decimator"),
    bits: ControlSpec(2, 24, \lin, 0, 24, units:"decimator"),
    decimator_input: ControlSpec(0, 2, \lin, 0, 1, units:"decimator"),
    decimator_output: ControlSpec(0, 2, \lin, 0, 1, units: "decimator"),
    decimator_mix: ControlSpec(0, 2, \lin, 0, 1, units: "decimator")
]
)
