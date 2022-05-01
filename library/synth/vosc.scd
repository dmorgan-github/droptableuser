(
synth: {|freq, gate|
    var start = \wtstart.kr(0);
    var end = \wtend.kr(0);
    var pos = SinOsc.ar({ Rand(0.01, 0.05) }.dup, { Rand(-1.0, 1.0) }.dup).range(start, end);
    var sig = VOsc.ar(pos, freq);
    sig;
}
)