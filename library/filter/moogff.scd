(
synth: {|in, gate, freq|

    var feg = Require(App.librarydir ++ "filter/feg.scd");
    var cutoff, res;
    #cutoff, res = feg.(freq, gate);
    MoogFF.ar(in, cutoff, gain:res.clip(0.0, 4.0))
}
)