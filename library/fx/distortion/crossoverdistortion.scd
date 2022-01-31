(
synth: {arg sig_in;

    var in = sig_in * \cod_input.ar(1, spec:ControlSpec(0, 2, \lin, 0, 1, units:"vol"));
    var mix = \cod_mix.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5));
    var sig = in;

    sig = BHiShelf.ar(sig,
        \cod_hishelfFreqPre.kr(16000, spec: ControlSpec(20, 20000, 'exp', 0, 16000, "hishelf_pre")),
        db:\cod_hishelfDbPre.kr(0, spec: ControlSpec(-120, 0.0, 'db', 0.0, 0, "hishelf_pre"))
    );

    sig = BLowShelf.ar(sig,
        \cod_loshelfFreqPre.kr(80, spec: ControlSpec(20, 20000, 'exp', 0, 80, "loshelf_pre")),
        db:\cod_loshelfDbPre.kr(0, spec: ControlSpec(-120, 0.0, 'db', 0.0, 0, "loshelf_pre"))
    );

    sig = CrossoverDistortion.ar(in,
        amp: \cod_crossover.ar(0.5, spec:ControlSpec(0.001, 1, \lin, 0, 0.5, units:"dist")),
        smooth: \cod_smooth.ar(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, units:"dist"))
    );

    sig = LeakDC.ar(sig) * 0.3;

    sig = BHiShelf.ar(sig,
        \cod_hishelfFreqPost.kr(16000, spec: ControlSpec(20, 20000, 'exp', 0, 16000, "hishelf_post")),
        db:\cod_hishelfDbPost.kr(0, spec: ControlSpec(-120, 0.0, 'db', 0.0, 0, "hishelf_post"))
    );

    sig = BLowShelf.ar(sig,
        \cod_loshelfFreqPost.kr(80, spec: ControlSpec(20, 20000, 'exp', 0, 80, "loshelf_post")),
        db:\cod_loshelfDbPost.kr(0, spec: ControlSpec(-120, 0.0, 'db', 0.0, 0, "loshelf_post"))
    );

    sig = in.blend(sig, mix);
    sig = sig * \cod_output.ar(1, spec: ControlSpec(0, 2, \lin, 0, 1, units: "vol"));
    sig;
}
)