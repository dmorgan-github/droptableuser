// Inharmonic string — DynGen port of Mutable Instruments Rings string.cc
// Karplus-Strong / waveguide string with two flavors of inharmonicity
// selectable via STRUCTURE:
//   structure < 0.24 → curved-bridge non-linearity (drum/bell/metallic)
//   structure ≈ 0.25 → perfectly harmonic (small dead zone)
//   structure > 0.26 → all-pass dispersion (sharp partials = stiff string)
// Sample-accurate feedback runs in the EEL2 VM, no SC block-latency floor.
//
// IMPORTANT: call InharmonicString.send(s) once after server boot
// (or in your startup) before instantiating any synths that use it.
//
// Args (all may be UGens at any rate):
//   in         — exciter input (audio); typically a short noise burst
//   freq       — fundamental in Hz
//   damping    — 0..1, RT60 from 0.5 s to 8 s (frequency-compensated)
//   brightness — 0..1, in-loop FIR damping blend (1 = bright, 0 = dark)
//   structure  — 0..1, inharmonicity character:
//                  0    → strong negative dispersion (bell/drum knock)
//                  0.25 → harmonic (dead zone 0.24..0.26)
//                  1    → strong positive dispersion (stiff piano string)
//   position   — 0..1, pickup position via comb filter on loop output

InharmonicString {
    classvar <code = "
@param freq: 220
@param damping: 0.7
@param brightness: 0.6
@param structure: 0.6
@param position: 0.25

@init
bufSize = 4096;
buf = 0;
writePos = 0;
xPrev = 0;
ap1 = 0; ap2 = 0; ap3 = 0; ap4 = 0;
curvedBridge = 0;
i = 0;
loop(bufSize, buf[i] = 0; i += 1;);

@block
// Rings structure → bipolar dispersion (-1..+1) with a small dead zone
// around 0.25 where the string is perfectly harmonic.
struct_ = _structure;
disp = (struct_ < 0.24) ? ((struct_ - 0.24) * 4.166)
     : (struct_ > 0.26) ? ((struct_ - 0.26) * 1.35135)
     : 0;

// All-pass coefficient. Positive dispersion only — first-order all-pass
// cascade pushes partials sharp.
g = max(disp, 0) * 0.7;

// Bridge-curving non-linearity. Negative dispersion only — modulates
// loop content based on a half-wave-rectified signal envelope.
bridgeRaw = max(-disp, 0);
bridgeAmt = bridgeRaw * bridgeRaw * 0.01;

// Frequency-compensated loop gain (constant RT60 across pitch).
RT60 = 0.5 + 7.5 * _damping;
loopGain = exp(-6.908 / (_freq * RT60));
loopGain = min(loopGain, 0.9999);

// Period compensation. Only the all-pass cascade adds excess delay,
// proportional to dispersion magnitude.
periodComp = 4 + 18 * max(disp, 0);

@sample
period = srate / _freq - periodComp;
period = max(min(period, bufSize - 4), 4);

// Delay-line read with linear interpolation.
readPos = writePos - period;
readPos += (readPos < 0) * bufSize;
readInt = floor(readPos);
readFrac = readPos - readInt;
readNext = readInt + 1;
readNext -= (readNext >= bufSize) * bufSize;
s = buf[readInt] + readFrac * (buf[readNext] - buf[readInt]);

// Dispersion all-pass (4 stages, only active when structure > 0.26).
t = -g * s + ap1; ap1 = s + g * t; s = t;
t = -g * s + ap2; ap2 = s + g * t; s = t;
t = -g * s + ap3; ap3 = s + g * t; s = t;
t = -g * s + ap4; ap4 = s + g * t; s = t;

// Curved-bridge non-linearity (only active when structure < 0.24).
// Asymmetric half-wave shaper: positive sign = +1, negative sign = -1.5
// → DC-asymmetric distortion that sounds like a struck-bridge knock.
val = abs(s) - 0.025;
sign = (s > 0) ? 1 : -1.5;
curvedBridge = (abs(val) + val) * sign;
s = s - curvedBridge * bridgeAmt;

// FIR damping (KS-style two-tap average), blended by brightness.
smoothed = (s + xPrev) * 0.5;
xPrev = s;
s = _brightness * s + (1 - _brightness) * smoothed;

// Mix in exciter, apply loop gain. Loop is fully linear — loopGain < 1
// alone is enough for stability.
s = s + in0;
s = s * loopGain;

buf[writePos] = s;

// Position pickup tap (comb on loop output).
combDelay = period * _position;
combPos = writePos - combDelay;
combPos += (combPos < 0) * bufSize;
combInt = floor(combPos);
combFrac = combPos - combInt;
combNext = combInt + 1;
combNext -= (combNext >= bufSize) * bufSize;
pickup = buf[combInt] + combFrac * (buf[combNext] - buf[combInt]);

out0 = s - pickup * 0.5;

writePos += 1;
writePos -= (writePos >= bufSize) * bufSize;
";

    *defName { ^\inharmonicString }

    *send { |server|
        ^DynGenDef(this.defName, code).send(server);
    }

    *free { |server|
        ^DynGenDef(this.defName).free(server);
    }

    *ar { |in, freq = 220, damping = 0.7, brightness = 0.6,
           structure = 0.6, position = 0.25|
        ^DynGen.ar(
            numOutputs: 1,
            script: this.defName,
            inputs: in,
            params: [
                freq:       freq,
                damping:    damping,
                brightness: brightness,
                structure:  structure,
                position:   position
            ],
            sync: 1.0
        );
    }
}
