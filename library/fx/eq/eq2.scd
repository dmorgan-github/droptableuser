(
synth: {|in|

    var sig = in;
    sig = BLowShelf.ar(sig,
        freq: \lowshelf.kr(40, spec:DMControlSpec(20, 220, \exp, 0, 40, "eq2", sort:0)),
        rs: \lowshelfres.kr(0, spec:DMControlSpec(0, 1, \lin, 0, 0, "eq2", sort:1)).linlin(0, 1, 1, 0.001),
        db: \lowshelfdb.kr(0, spec:DMControlSpec(-24, 24, \lin, 0, 0, "eq2", sort:2))
    );
    sig = BHiShelf.ar(sig,
        freq: \hishelf.kr(16000, spec:DMControlSpec(2000, 20000, \exp, 0, 16000, "eq2", sort:3)),
        rs: \hishelfres.kr(0, spec:DMControlSpec(0, 1, \lin, 0, 0, "eq2", sort:4)).linlin(0, 1, 1, 0.001),
        db: \hishelfdb.kr(0, spec:DMControlSpec(-24, 24, \lin, 0, 0, "eq2", sort:5))
    );
    sig;
}
)