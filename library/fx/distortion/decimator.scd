(
synth: {|in|

    /*
    var samplerate = s.sampleRate * 0.1;
    var bitsize = 8;
    var sig = Latch.ar(in, Impulse.ar(samplerate));
    sig = sig.round(0.5 ** bitsize);
    sig = in.blend(sig, \decimate_mix1.kr(0.7, spec:ControlSpec(0, 1, \lin, 0, 0.5, "decimate")));
    sig;
    */

    var samplerate = Server.default.sampleRate;
    var sig = Decimator.ar(in,
        \decimator_rate.kr(1, spec: ControlSpec(1/16, 1, \lin, 0, 1, "decimator")).clip(1/16, 1) * samplerate,
        \decimator_bits.kr(24, spec: ControlSpec(1, 24, \lin, 0, 24, "decimator")).clip(1, 24)
    );
    sig = in.blend(sig, \decimator_mix.kr(0.7, spec: ControlSpec(0, 1, \lin, 0, 0.7, "decimator")));
    sig
}
)
