// Modal resonator inspired by Mutable Instruments Elements (resonator.cc).
// A bank of bandpass filters whose frequencies, decays, and amplitudes
// model a struck/plucked physical object. Feed it an exciter (impulse,
// noise burst, scratch) and the bank rings out as the modes decay.
//
// Args (all may be control/audio-rate UGens unless noted):
//   in         — exciter input (audio)
//   freq       — fundamental in Hz
//   structure  — 0..1, partial stretching:
//                  0   = compressed (metallic, partials sub-harmonic)
//                  0.5 = harmonic
//                  1   = stiff string (partials sharp)
//   brightness — 0..1, geometric decay across modes:
//                  0 = dark (HF dies fast), 1 = bright (HF rings)
//   damping    — 0..1, overall decay time (0 ≈ 50 ms, 1 ≈ 8 s)
//   position   — 0..1, pickup position; mode n is nulled when
//                position * n is an integer (string-pluck model)
//   numModes   — integer, mode count (BUILD TIME, default 32)
//
// Usage:
//   SynthDef(\modal, { |freq=220, gate=1|
//       var trig    = Impulse.ar(0);
//       var exciter = Decay.ar(trig, 0.002) * PinkNoise.ar(0.5);
//       var sig     = ModalResonator.ar(
//           exciter,
//           freq,
//           structure:  \structure.kr(0.5),
//           brightness: \brightness.kr(0.6),
//           damping:    \damping.kr(0.7),
//           position:   \position.kr(0.25)
//       );
//       Out.ar(0, sig.tanh.dup * 0.4);
//   }).add;

ModalResonator {
    *ar { |in, freq = 110, structure = 0.5, brightness = 0.5,
           damping = 0.5, position = 0.25, numModes = 32|
        var stiffness, ratios, freqs, ringTimes, amps, nyquistMask;

        // Map structure → cumulative stretch coefficient.
        // Negative values pull partials together (drum/bell-like);
        // positive values push them apart (stiff string).
        stiffness = structure.linlin(0, 1, -0.25, 0.5);

        // Partial ratios: partial[i] = (i+1) * (1 + i * stiffness).
        // Floor at 0.01 so negative stiffness can't fold to DC.
        ratios = Array.fill(numModes, { |i|
            ((i + 1) * (1 + (i * stiffness))).max(0.01)
        });

        freqs = ratios * freq;

        // Geometric decay across modes: ring[i] = base * brightness^i.
        // base is the fundamental's ring time (set by `damping`).
        ringTimes = Array.fill(numModes, { |i|
            var base   = damping.linexp(0, 1, 0.05, 8);
            var bright = brightness.linlin(0, 1, 0.3, 1.0);
            base * bright.pow(i)
        });

        // Pickup position via comb in modal domain: amp[i] = sin(π * pos * n).
        // This gives the standard "plucked-string" amplitude profile:
        // mode n is silent when position lands on one of its nodes.
        amps = Array.fill(numModes, { |i|
            sin(pi * position * (i + 1))
        });

        // Mute any partial that would fold above (near) Nyquist.
        nyquistMask = Array.fill(numModes, { |i|
            freqs[i] < (SampleRate.ir * 0.49)
        });
        amps = amps * nyquistMask;

        ^DynKlank.ar(`[freqs, amps, ringTimes], in);
    }
}
