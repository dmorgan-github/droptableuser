(
synth: {|freq, gate, aeg|

    var sig, trig, decay, coef, bright, exciter;
    trig = gate;//Impulse.ar(0);
    decay = \pluckdecay.kr(0.505, spec: ControlSpec(0, 1, \lin, 0, 0.505, units:"pluck")).linlin(0, 1, -8, 8);
    coef = \coef.kr(0.6, spec: ControlSpec(0, 1.0, \lin, 0, 0.6, units:"pluck")).linlin(0, 1, -0.1, 1.0);
    bright = \bright.kr(0.9, spec:ControlSpec(0, 1, \lin, 0, 0.9, "pluck"));
    //exciter = ~exciter ?? { Hasher.ar(Sweep.ar(trig)) };
    exciter = ~exciter ?? { BrownNoise.ar * 0.5 };
    exciter = LPF.ar(exciter, bright.linlin(0, 1, 20, 20000).clip(20, 20000));

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
