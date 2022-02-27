(
synth: {|in|

    var sig = in;
    [30, 60, 120, 250, 500, 1000, 2000, 4000, 8000, 12000, 16000].do({|hz, i|
        var key = "%hz".format(hz).asSymbol;
        sig = BPeakEQ.ar(sig, hz, db:key.kr(0, spec:DMControlSpec(-24, 24, \lin, 0, 0, "eq", sort:i)));
    });
    sig = in.blend(sig, \eq_mix.kr(1, spec:DMControlSpec(0, 1, \lin, 0, 1, units:"eq", sort:100)));
    sig;
}
)