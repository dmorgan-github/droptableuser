(
synth: {|in, gate, freq, aeg|

    var feg = Require(App.librarydir ++ "filter/feg.scd");
    var cutoff, res;
    #cutoff, res = feg.(freq, gate, aeg);
    MoogFF.ar(in, cutoff, gain:res.clip(0.0, 4.0))
}
)