(
synth: {arg sig_in;

    var in = sig_in * \input.ar(1);
    var fblevel = \fb.ar(0.7);
    var del = \del.ar(6).lag(0.1);
    var size = ~fblongsize ?? 16;

    var sig = FbC({arg fb;
        fb.reverse * fblevel + Select.ar(fblevel > 0.99, [in, Silent.ar(2)])
    }, size, del);

    sig * \output.ar(1);
},
specs: [
    fb: ControlSpec(0.0, 1, \lin, 0.0, 0.7, units:"fx"),
    del: ControlSpec(1, 16, \lin, 1, 6, units:"fx"),
    input: ControlSpec(0, 2, \lin, 0, 1, units:"vol"),
    output: ControlSpec(0, 2, \lin, 0, 1, units: "vol")
]
)