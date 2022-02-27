(
synth: {|freq, gate, aeg|
    var sig;
    var trig = Impulse.ar(0);
    var decay = \pluckdecay.kr(0.9, spec: ControlSpec(-8, 8, \lin, 0, 0.9, units:"pluck"));
    var coef = \coef.kr(0.5, spec: ControlSpec(-0.1, 1.0, \lin, 0, 0.5, units:"pluck"));
    var bright = \bright.kr(0.9, spec:ControlSpec(0, 1, \lin, 0, 0.9, "pluck"));
    var exciter = ~exciter ?? {Hasher.ar(Sweep.ar(trig))};
    exciter = LPF(exciter, bright.linlin(0, 1, 20, 20000).clip(20, 20000));
    sig = Pluck.ar(
        exciter,
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
