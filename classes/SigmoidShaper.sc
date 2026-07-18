// Oversampled sigmoid wave-shaper distortion via DynGen.
//
// Distortion at the host sample rate creates harmonics that fold back as
// aliasing. This class runs the sigmoid at N× the host rate, low-passes
// at the host's Nyquist with a 4th-order Butterworth (two cascaded
// biquads), then decimates — pushing aliases far below audibility.
//
// IMPORTANT: call SigmoidShaper.send(s) once after server boot
// before instantiating any synths that use it.
//
// Args (all may be UGens):
//   in         — audio input
//   drive      — 0..1, distortion amount (linexp 1..100 internally)
//   mix        — 0..1, dry/wet
//   oversample — 1..16 (step-rate; integer); 4× is a good default
//   asym       — -1..1, DC bias before the sigmoid breaks symmetry to
//                introduce even harmonics. 0 = pure odd (fuzz/symmetric
//                clip), ±1 = strong even-harmonic content (tube-like
//                warmth). Steady-state DC is removed automatically.

SigmoidShaper {
    classvar <code = "
@param drive: 0
@param mix: 1
@param oversample: 4, step
@param asym: 0

@init
b1x1 = 0; b1x2 = 0; b1y1 = 0; b1y2 = 0;
b2x1 = 0; b2x2 = 0; b2y1 = 0; b2y2 = 0;

@block
osN     = max(1, min(16, floor(_oversample)));
gain    = exp(_drive * log(100));
outGain = 1 / sqrt(gain);

// Asymmetry: DC offset added before the sigmoid. Scaled by 0.5 so the
// max excursion lands ±0.5 inside the sigmoid's range. The static DC
// the offset induces is computed here and subtracted after shaping.
asymOff = _asym * 0.5;
asymDC  = asymOff / sqrt(1 + asymOff * asymOff);

// Anti-image / anti-alias LPF at the host's Nyquist (with a small
// margin so the transition band doesn't bleed into audible HF).
osRate = srate * osN;
fc     = srate * 0.475;
omega  = 2 * $pi * fc / osRate;
sw     = sin(omega);
cw     = cos(omega);
cw2    = 1 - cw;

// 4th-order Butterworth = two cascaded biquads with Q = 0.5412, 1.3066.
alpha1 = sw / (2 * 0.5412);
a0a = 1 + alpha1;
b0a = cw2 / 2 / a0a;
b1a = cw2 / a0a;
b2a = b0a;
a1a = -2 * cw / a0a;
a2a = (1 - alpha1) / a0a;

alpha2 = sw / (2 * 1.3066);
a0b = 1 + alpha2;
b0b = cw2 / 2 / a0b;
b1b = cw2 / a0b;
b2b = b0b;
a1b = -2 * cw / a0b;
a2b = (1 - alpha2) / a0b;

@sample
// Inner oversampling loop. Input is held constant across substeps
// (zero-order-hold upsampling); the LPF removes the spectral images
// the ZOH introduces above srate/2.
last = 0;
loop(osN,
    s = in0 * gain + asymOff;
    s = s / sqrt(1 + s * s);
    s = s - asymDC;

    // Biquad stage 1
    y1 = b0a*s + b1a*b1x1 + b2a*b1x2 - a1a*b1y1 - a2a*b1y2;
    b1x2 = b1x1; b1x1 = s;
    b1y2 = b1y1; b1y1 = y1;

    // Biquad stage 2
    y2 = b0b*y1 + b1b*b2x1 + b2b*b2x2 - a1b*b2y1 - a2b*b2y2;
    b2x2 = b2x1; b2x1 = y1;
    b2y2 = b2y1; b2y1 = y2;

    last = y2;
);

// Decimate: take only the last filtered substep. Apply level
// compensation, then dry/wet mix.
wet = last * outGain;
out0 = in0 + _mix * (wet - in0);
";

    *defName { ^\sigmoidShaper }

    *send { |server|
        ^DynGenDef(this.defName, code).send(server);
    }

    *free { |server|
        ^DynGenDef(this.defName).free(server);
    }

    *ar { |in, drive = 0, mix = 1, oversample = 4, asym = 0|
        // Spawn one DynGen instance per input channel so each side has
        // its own VM and biquad state. Returns a mono UGen for mono
        // input, a 2-element array for stereo, etc.
        ^in.asArray.collect { |chan|
            DynGen.ar(
                numOutputs: 1,
                script: this.defName,
                inputs: chan,
                params: [
                    drive:      drive,
                    mix:        mix,
                    oversample: oversample,
                    asym:       asym
                ],
                sync: 1.0
            );
        };
    }
}
