// Inharmonic stiff string — hybrid waveguide / modal.
//
// The waveguide branch (FbC) provides the rich KS/dispersion sound below
// SC's feedback-latency ceiling (≈ 1 / ControlDur, default ~650 Hz).
// Above that, a modal Klank bank takes over with the canonical
// stiff-string partial formula  fₙ = n · f₀ · √(1 + b · n²).
//
// CPU cost is roughly 2× a single string. To run more of the keyboard
// through the waveguide (better sound), set s.options.blockSize = 16
// (or smaller) and reboot — the waveguide ceiling rises proportionally.
//
// Args:
//   in         — exciter input (audio); typically a short noise burst
//   freq       — fundamental in Hz (UGen, modulatable)
//   damping    — 0..1, decay length              (UGen, modulatable)
//   brightness — 0..1, output LPF cutoff         (UGen, modulatable)
//   dispersion — 0..1, partial stretching        (BUILD-TIME number)
//   position   — 0..1, pickup/strike position    (BUILD-TIME number)
//   thumpAmp   — fundamental amplitude multiplier (BUILD-TIME number,
//                  modal branch only — boosts the lowest mode for body)
//   thumpDec   — fundamental decay multiplier    (BUILD-TIME number,
//                  modal branch only — extends the lowest mode's RT60)
//   numModes   — modal mode count                (BUILD-TIME, default 32)

StiffString {
    *ar { |in, freq = 220, damping = 0.5, brightness = 0.5,
           dispersion = 0.25, position = 0.2,
           thumpAmp = 1, thumpDec = 1, numModes = 32|

        var wgMaxFreq = 1 / ControlDur.ir;
        var wgFreq    = freq.clip(20, wgMaxFreq * 0.92);
        var wgSig, modalSig, mix;

        wgSig = this.prWaveguide(in, wgFreq, damping, brightness,
                                 dispersion, position);

        modalSig = this.prModal(in, freq, damping, brightness,
                                dispersion, position,
                                thumpAmp, thumpDec, numModes);

        mix = freq.linlin(wgMaxFreq * 0.65, wgMaxFreq * 0.92, 0, 1);

        ^((wgSig * (1 - mix)) + (modalSig * mix));
    }

    *prWaveguide { |in, freq, damping, brightness, dispersion, position|
        var maxDelay = 0.1, nApAll = 4;
        var period, dispCoef, loopGain, lpfHz, sig, pickup;

        period   = freq.reciprocal.clip(8 / SampleRate.ir, maxDelay);
        dispCoef = dispersion.linlin(0, 1, 0, 0.7);
        loopGain = damping.linlin(0, 1, 0.985, 0.9999);
        lpfHz    = (damping.sqrt * brightness).linexp(0, 1, 200, 16000);

        sig = FbC({ |fb|
            var x = fb + (in * 0.5);
            x = LPF.ar(x, lpfHz);
            nApAll.do {
                x = FOS.ar(x, dispCoef.neg, 1, dispCoef);
            };
            (x * loopGain).tanh
        }, maxDelay, period - (nApAll / SampleRate.ir));

        pickup = DelayC.ar(sig, maxDelay,
            (period * position).clip(2 / SampleRate.ir, maxDelay - 0.001));

        ^LeakDC.ar(sig - pickup);
    }

    *prModal { |in, freq, damping, brightness, dispersion, position,
                thumpAmp, thumpDec, numModes|
        var b, ratios, ringTimes, amps, decayShape, sig;

        b          = dispersion.linlin(0, 1, 0, 0.008);
        decayShape = 0.6;  // baked geometric per-mode decay falloff

        ratios = Array.fill(numModes, { |i|
            var n = i + 1;
            n * sqrt(1 + (b * n.squared))
        });

        ringTimes = Array.fill(numModes, { |i|
            var natural = decayShape.pow(i);
            if (i == 0) { natural * thumpDec } { natural }
        });

        amps = Array.fill(numModes, { |i|
            var n = i + 1;
            var amp = sin(pi * position * n) / n;
            if (i == 0) { amp * thumpAmp } { amp }
        });

        // Klank with freqscale = freq (UGen) and decayscale = damping (UGen).
        // Spec arrays are static Numbers → coefficients computed once at
        // SynthDef build, runtime modulation only via the two scales.
        sig = Klank.ar(
            `[ratios, amps, ringTimes],
            in,
            freqscale:  freq,
            decayscale: damping.linexp(0, 1, 0.05, 8)
        );

        // Brightness as post-Klank LPF (modulatable)
        sig = LPF.ar(sig, brightness.linexp(0, 1, 200, 16000));

        ^LeakDC.ar(sig.tanh);
    }
}
