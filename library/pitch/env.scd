(
synth: {|gate|
    var freq = \freq.ar(261);
    var atk = \freqatk.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, "pitch"));
    var rel = \freqrel.kr(0.01, spec:ControlSpec(0, 1, \lin, 0, 0, "pitch"));
    var atkcurve = \freqatkcurve.kr(-4, spec:ControlSpec(-8, 8, \lin, 0, -4, "pitch"));
    var relcurve = \freqrelcurve.kr(-4, spec:ControlSpec(-8, 8, \lin, 0, -4, "pitch"));
    var freqmul = \freqmul.kr(0, spec: ControlSpec(0, 4, \lin, 0, 0, "pitch"));
    var fenv = Env.perc(atk, rel, curve:[atkcurve, relcurve]).ar(gate:gate) * freqmul;
    freq = freq * (1+fenv);
    freq;
}
)