// 6-shape selectable LFO with modulatable phase and trigger-based reset.
// All inputs are normalised 0..1 (except `reset`, a trigger).
//   shape: 0=sine 0.2=tri 0.4=sqr 0.6=ramp↑ 0.8=ramp↓ 1=random
//   phase: 0..1 fraction of one cycle (modulatable; values outside 0..1 wrap)
//   reset: trigger — on positive transition the phasor jumps to `phase` and
//          a fresh random target is sampled.
// Output is bipolar (-1..1).

LFO {
    *kr { |freq = 1, shape = 0, phase = 0, reset = 0|
        var basePhase, ph, rampTrig, randTarget, rampTarget, shapes, shapeIdx;

        basePhase = Phasor.kr(reset, freq / ControlRate.ir, 0, 1, phase);
        ph        = (basePhase + phase).wrap(0, 1);

        rampTrig   = Impulse.kr(freq) + reset;
        randTarget = TRand.kr(-1.0, 1.0, rampTrig);
        rampTarget = Lag.kr(randTarget, freq.reciprocal);

        shapes = [
            sin(ph * 2pi),                       // sine
            1 - ((ph - 0.5).abs * 4),            // triangle
            (ph < 0.5) * 2 - 1,                  // square
            ph * 2 - 1,                          // ramp up
            1 - (ph * 2),                        // ramp down
            rampTarget                           // random
        ];
        shapeIdx = (shape * 5).round(1).asInteger.clip(0, 5);
        ^Select.kr(shapeIdx, shapes);
    }
}
