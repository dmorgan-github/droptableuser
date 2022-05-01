(
synth: {|in, gate, freq|

    var feg = Require(App.librarydir ++ "filter/feg.scd");
    var cutoff, res;
    #cutoff, res = feg.(freq, gate);
    DFM1.ar(in, cutoff, res.clip(0.0, 1.4))
}
)