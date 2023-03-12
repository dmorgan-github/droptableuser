(
synth: {|in, gate, freq, aeg|

    var feg = Require(Module.libraryDir ++ "filter/feg.scd");
    var cutoff, res;
    #cutoff, res = feg.(freq, gate, aeg);
    res = res.linlin(0, 1, 1.4, 0.05);
    BLowPass4.ar(in, cutoff, rq:res.clip(0.05, 1.4));
}
)
