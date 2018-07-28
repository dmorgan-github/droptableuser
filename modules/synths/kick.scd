b = Buffer.alloc(s, 512, 1, { |buf| buf.chebyMsg([0,0.6,2])});
(SynthDef(\kick, {arg freq = 50, amp=0.5;

    var amp_env, phase_env, phase, dur, out;
    dur = 0.25;
    amp_env = EnvGen.ar(Env.perc(1e-6,dur), doneAction:2);
    phase_env = EnvGen.ar(Env.perc(1e-6,0.125));

    phase = SinOsc.ar(20,0,pi) * phase_env;
    out = (Impulse.ar(0) + SinOsc.ar(freq,phase)) * amp_env * amp;
    out = LeakDC.ar(Shaper.ar(b, out));
    out = LPF.ar(out, 2500);
    out = HPF.ar(out, 30);
    Out.ar(0, out!2);
}).add)
};


(
Pbind(
    \instrument, "kick",
    \dur, Pseq([Pbjorklund2(3,8), Pbjorklund2(5,8)], inf) * 0.25,
    \att, 0.01,
    \rel, 0.22,
    \freq, 60,
    \glissf, 0.9,
    \amp, 1,
).play;
)