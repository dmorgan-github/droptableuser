(
synth: {|freq, gate|

    var exciter = ~exciter ?? Env.perc(0.0, 0.1).ar(gate:gate);
    var pos = \position.kr(0.001, spec:ControlSpec(0, 1, \lin, 0, 0.001, units:"resonator"));
    var res = 24;//\resolution.kr(24, spec:ControlSpec(1, 24, \lin, 1, 24, units:"resonator"));
    var struct = \struct.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, units:"resonator"));
    var bright = \bright.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, units:"resonator"));
    var damp = \damp.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, units:"resonator"));
    var sig = Resonator.ar(exciter, freq, pos, res, struct, bright, damp);
    sig = sig;
    sig;
}
)
