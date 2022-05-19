(
synth: {|in|
    var sig = in;
    var ratio = \compressratio.kr(4, spec:ControlSpec(1, 40, \lin, 0, 4, "compress"));
    var thresh = \compressthresh.kr(0, spec:ControlSpec(-80, 0, \lin, 0, 0, "compress"));
    var atk = \compressatk.kr(0.1, spec:ControlSpec(0.001, 10, \lin, 0, 0.1, "compress"));
    var rel = \compressrel.kr(1, spec:ControlSpec(0.001, 10, \lin, 0, 1, "compress"));
    var makeup = \compressmakeup.kr(0.5, spec:ControlSpec(0, 80, \lin, 0, 0.5, "compress"));
    var automakeup = \compressautomakeup.kr(1, spec:ControlSpec(0, 1, \lin, 1, 1, "compress"));
    sig = DCompressor.ar(sig,
        ratio:ratio,
        threshold:thresh,
        attack:atk,
        release:rel,
        makeup:makeup,
        automakeup:automakeup
    );
    sig = in.blend(sig, \compressmix.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, "compress")));
    sig;
}
)