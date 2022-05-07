(
synth: {|freq, gate|
    var start = \wtstart.kr(0);
    var end = \wtend.kr(0);
    var pos = SinOsc.ar({ Rand(0.01, 0.1) }.dup, { Rand(-1.0, 1.0) }.dup).range(start, end);
    //var pos = start + SinOsc.kr(1, { Rand(-1.0, 1.0) }.dup);
    var sig = VOsc.ar(pos, freq);
    sig;
}
)