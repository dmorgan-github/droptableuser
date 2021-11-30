(
synth: {arg sig_in;

    var in = sig_in * \fblong_input.ar(1);
    var fblevel = \fblong_fb.ar(0.7);
    var del = \fblong_del.ar(6).lag(0.1);
    var size = ~fblongsize.debug("fblongsize") ?? 16;

    var sig = FbC({arg fb;
        fb.reverse * fblevel + Select.ar(fblevel > 0.99, [in, Silent.ar(2)])
    }, size, del);

    sig = in.blend(sig, \fblong_mix.kr(0.5));
    sig = sig * \fblong_output.ar(1);
    sig;

},
specs: [
    fblong_fb: ControlSpec(0.0, 1, \lin, 0.0, 0.7, units:"fx"),
    fblong_del: ControlSpec(1, 20, \lin, 1, 6, units:"fx"),
    fblong_input: ControlSpec(0, 2, \lin, 0, 1, units:"vol"),
    fblong_output: ControlSpec(0, 2, \lin, 0, 1, units: "vol"),
    fblong_mix: ControlSpec(0, 1, \lin, 0, 0.4, "vol")
]
)