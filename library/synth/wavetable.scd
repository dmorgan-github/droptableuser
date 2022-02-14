(
synth: {|freq|
    var buf = \buf.kr(0);
    var sig = COsc.ar(buf, freq, \beats.kr(0.5));
    sig;

}
)