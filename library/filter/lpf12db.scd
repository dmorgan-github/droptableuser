(
synth: {|in, gate, freq|

    var feg = Require(App.librarydir ++ "filter/feg.scd");
    var cutoff, res;
    #cutoff, res = feg.(freq, gate);
    BLowPass.ar(in, cutoff, rq:res.clip(0.05, 1.4));
}
)