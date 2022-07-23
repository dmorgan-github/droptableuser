(
synth: {|in| 
    var sig = Decimator.ar(in, 
        \decimator_rate.kr(1, spec: ControlSpec(1/16, 1, \lin, 0, 1, "decimator")).clip(1/16, 1) * 44100, 
        \decimator_bits.kr(24, spec: ControlSpec(2, 24, \lin, 0, 24, "decimator")).clip(2, 24)
    );
    sig = in.blend(sig, \decimator_mix.kr(0.7, spec: ControlSpec(0, 1, \lin, 0, 0.3, "decimator")))
}
)
