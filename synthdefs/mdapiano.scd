(
SynthDef(\help_mdapiano, { |out=0, freq=440, gate=1|
    var son = MdaPiano.ar(freq, gate, release: 0.9, stereo: 0.3, sustain: 0);
    DetectSilence.ar(son, 0.01, doneAction:2);
    Out.ar(out, son * 0.1);
}).add;
)