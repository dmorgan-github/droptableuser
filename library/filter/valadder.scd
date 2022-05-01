(
synth: {|in, gate, freq|
    var feg = Require(App.librarydir ++ "filter/feg.scd");
    var cutoff, res, type, overdrive;
    #cutoff, res = feg.(freq, gate);
    type = \type.kr(0, spec: DMControlSpec(0, 5, \lin, 1, 0, units:"filter", sort:0));
    overdrive = \overdrive.kr(0, spec:DMControlSpec(0, 1, \lin, 0, 0, "filter", sort:100));
    VALadder.ar(in, cutoff, res, overdrive, type);
}
)