https://scsynth.org/t/hardsync-of-two-phasors/8588/5

(
    { |innerLoop = 2, outerLoop = 8|
        var rate = 2;
        var a = (Phasor.ar(0, rate * SampleDur.ir * innerLoop, 0, 1) - SampleDur.ir).wrap(0, 1);
        var b = (Phasor.ar(Slope.ar(a), rate * SampleDur.ir * outerLoop, 0, 1) - SampleDur.ir).wrap(0, 1);
        var c = Trig1.ar(Slope.ar(b), SampleDur.ir);
        [a, b, c];
    }.plot(1);
)