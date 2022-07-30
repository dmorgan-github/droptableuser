(
synth: {arg in;

    var fblevel = \fblong_fb.ar(0.7, spec:ControlSpec(0.0, 1, \lin, 0.0, 0.7, units:"fb_long"));
    var del = \fblong_del.ar(6, spec:ControlSpec(1, 20, \lin, 1, 6, units:"fb_long")).lag(0.1);
    var size = ~fblongsize ?? 16;

    var sig = FbC({arg fb;
        fb.reverse * fblevel + Select.ar(fblevel > 0.99, [in, Silent.ar(2)])
    }, size.debug("fblongsize"), del);

    sig = in.blend(sig, \fblong_mix.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.4, "fb_long")));
    sig;
}
)