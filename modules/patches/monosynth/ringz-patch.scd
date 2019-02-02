(
Ndef(\ringz, {
    var trigs = (0..3).collect({arg val;
        var trig = ('trig' ++ val).asSymbol;
        Latch.ar(BrownNoise.ar, trig.tr);
    });
    var sig = trigs[0..2].collect({arg trig, i;
        var freq = ('f' ++ i).asSymbol.kr(261);
        Formlet.ar(trig, freq, 0.001, 0.7) * AmpCompA.kr(freq) * -12.dbamp;
    });
    sig = sig ++ [Formlet.ar(trigs[3], \f3.kr(261) * SinOsc.kr(15).range(9, 12).midiratio, 0.005, 2) * AmpCompA.kr(\f3.kr) * -16.dbamp];
    sig = Limiter.ar(sig.sum, -3.dbamp);
    sig = Pan2.ar(sig, LFNoise2.kr(1).range(-1.0, 1.0)) * \amp.kr(-6.dbamp);
    sig = AllpassC.ar(sig, 0.1, SinOsc.kr(0.01).range(0.05, 0.1), 15);
    sig = Squiz.ar(sig.reverse, [7, 12].midiratio, LFNoise2.kr(1/8).range(2, 60)) * LFNoise2.kr(0.1).range(0, 0.3) + sig;
    sig = NHHall.ar(sig, 5) * -6.dbamp + sig;
    sig;
});
Ndef(\ringz)[2] = \set -> Ppar(
    [
        72 -> [31, 24, 5],
        75 -> [25, 21, 13],
        79 -> [23, 43, 53],
        82 -> [26, 56, 61]
    ].collect({arg assoc, i;
        var note = assoc.key.midicps;
        var divs = assoc.value;
        divs.collect({arg div;
            var trig = ('trig' ++ i).asSymbol;
            var freq = ('f' ++ i).asSymbol;
            Pbind(trig, 1, freq, note * Prand([-12, 0, -7, 7, 12].midiratio, inf), \dur, div * 0.25)
        });
    }).flatten
);
Ndef(\ringz).clock_(TempoClock.new(60/60).permanent_(true)).play;
)