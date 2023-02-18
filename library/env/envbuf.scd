
(
synth: {|gate, doneAction=(Done.freeSelf)|
    var buf = \envbuf.kr(0);
    var ts = \ts.kr(1);
    PlayBuf.ar(1, buf, BufRateScale.kr(buf) * ts, 1, 0, 0, doneAction:Done.freeSelf);
},
props: (
    hasgate: false
)
)


