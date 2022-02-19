(
synth: {|freq, gate, aeg|
    var trig = Impulse.ar(0);
    var decay = \pluckdecay.kr(0.9, spec: ControlSpec(0.01, 1.0, \lin, 0, 0.9, units:"pluck"));
    var coef = \coef.kr(0.5, spec: ControlSpec(-1.0, 1.0, \lin, 0, 0.5, units:"pluck"));
    var sig = Pluck.ar(
        Hasher.ar(Sweep.ar(trig)),
        trig,
        freq.reciprocal,
        freq.reciprocal,
        decaytime:decay,
        coef:coef
    );
    sig = LeakDC.ar(sig);
    sig;
}
)
