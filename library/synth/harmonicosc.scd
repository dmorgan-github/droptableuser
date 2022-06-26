(
synth:{|freq|

    var first = \firstharmonic.kr(1, spec:DMControlSpec(1, 16, \lin, 1, 1, units:"harmonicosc", sort:17));
    var amps = 16.collect({|i|
        var num = i+1;
        var key = "harm%".format(num).asSymbol;
        var val = num.reciprocal;
        key.kr(val, spec:DMControlSpec(0, 1, \lin, 0, val, units:"harmonicosc", sort:num));
    });
    var sig = HarmonicOsc.ar(freq, first, amps);
    sig = BHiShelf.ar(sig, 16000, 1.0, -60);
    sig;
}
)