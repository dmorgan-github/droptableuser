(
SynthDef(\snare, {
    var snd, freq;
    freq = XLine.ar(800, 201, 0.02) * \transpose.kr(0).midiratio;
    snd = SinOsc.ar(freq) * Env.perc(0.01, 0.1).ar;
    snd = (snd * 8).tanh * -2.dbamp;
    snd = FreqShift.ar(snd, -20);
    snd = snd + (BPF.ar(WhiteNoise.ar, 3000, 1.0) * Env.perc(0.01, 0.05).ar);
    snd = snd + (BPF.ar(WhiteNoise.ar, 2300, 1.0) * Env.perc(0.1, 0.15).ar);
    snd = snd * Env.asr(0, 1, 0.03).ar(2, \gate.kr(1));
    Out.ar(\out.kr(0), Pan2.ar(snd, \pan2.kr(0), \amp.kr(0.1)));
}).add;
)
Synth(\snare, [amp: 0.8]);