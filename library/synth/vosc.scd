(
synth: {|freq, gate|

    var tune = ~tune ?? false;
    var start = \wtstart.kr(0);
    var end = \wtend.kr(0);
    var pos, sig;
    if (tune.debug("tune")) {
        pos = MouseX.kr(start, end).poll;
    }{
        pos = SinOsc.ar({ Rand(0.01, 0.1) }.dup, { Rand(-1.0, 1.0) }.dup).range(start, end-1);
    };
    sig = VOsc.ar(pos, freq);
    sig;
}
)