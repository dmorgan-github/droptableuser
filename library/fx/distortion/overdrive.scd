(
synth: {arg sig_in;

    var gain, sig, hi, lo;
    var in = sig_in * \input.ar(1);
    hi = HPF.ar(in, \hpf.kr(200));
    lo = hi - in;
    gain = [\gainL.ar(1).lag(0.01), \gainR.ar(1).lag(0.01)];
    sig = SoftClipAmp8.ar(hi, gain) * (gain.reciprocal.sqrt);
    sig = LeakDC.ar(sig) * 0.6;
    sig = sig + lo;
    Splay.ar(sig,
        spread:\spread.ar(1),
        center:\pan.ar(0)
    ) * \output.ar(1);
},
specs: [
    \gainL -> ControlSpec(1, 100, \lin, 0, 1, units:"fx"),
    \gainR -> ControlSpec(1, 100, \lin, 0, 1, units:"fx"),
    \hpf -> ControlSpec(20, 2000, \lin, 0, 80, units:"fx"),
    \spread -> ControlSpec(0,1,\lin,0, 1, units:"stereo"),
    \pan -> ControlSpec(-1,1,\lin,0,0, units:"stereo"),
    \input -> ControlSpec(0, 2, \lin, 0, 1, units:"vol"),
    \output -> ControlSpec(0, 2, \lin, 0, 1, units: "vol")
]
)