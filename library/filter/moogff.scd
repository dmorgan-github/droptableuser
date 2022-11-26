(
synth: {|in, gate, freq, aeg|

    var feg = Require(App.librarydir ++ "filter/feg.scd");
    var cutoff, res, gain;
    #cutoff, res = feg.(freq, gate, aeg);
    MoogFF.ar(in, cutoff, gain:res.linlin(0, 1, 0, 4).clip(0.0, 4.0));
}
)