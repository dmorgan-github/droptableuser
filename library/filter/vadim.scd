(
synth: {|in, gate, freq|

    var feg = Require(App.librarydir ++ "filter/feg.scd");
    var cutoff, res, type;
    #cutoff, res = feg.(freq, gate);
    type = \type.kr(0, spec: DMControlSpec(0, 5, \lin, 1, 0, units:"filter", sort:0));
    VadimFilter.ar(in, cutoff, res, type);
}
)