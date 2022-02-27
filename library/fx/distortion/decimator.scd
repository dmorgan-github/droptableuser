(
synth: {arg sig_in;

    var in = sig_in * \decimator_input.ar(1);
    var sig = Decimator.ar(in,
        rate: \samplerate.ar(41000, spec: ControlSpec(0, 41000, \lin, 0, 41000, units:"decimator")),
        bits: \bits.ar(24, spec: ControlSpec(2, 24, \lin, 0, 24, units:"decimator"))
    );

    sig = LeakDC.ar(sig);
    sig = in.blend(sig, \decimator_mix.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units: "decimator")));
    sig * \decimator_output.ar(1);
}
)
