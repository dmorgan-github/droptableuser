(
synth: {|freq, gate, aeg|
	var trig = Impulse.ar(0);
    var decay = \puckdecay.kr(0.9);
    var coef = \coef.kr(0.5);
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
},
specs: [
    pluckdecay: ControlSpec(0.01, 1.0, \lin, 0, 0.9),
    coef: ControlSpec(-1.0, 1.0, \lin, 0, 0.5)
]
)
