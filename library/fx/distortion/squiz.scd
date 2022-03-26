(
synth: {arg sig_in;

    var in = sig_in;
    var sig = Squiz.ar(in,
        pitchratio: \pitchratio.ar(12, spec:ControlSpec(1, 24, \lin, 1, 12, "squiz")).midiratio,
        zcperchunk: \zcperchunk.ar(1, spec:ControlSpec(1, 100, \lin, 0, 1, "squiz")).lag(0.05)
    );
    sig = LeakDC.ar(sig);
    sig = in.blend(sig, \squiz_mix.kr(0.3, spec: ControlSpec(0, 1, \lin, 0, 0.3, "squiz")));
    sig;
}
)