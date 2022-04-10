(
synth: {|freq|

    var sig;
    var pw = \pw.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, "varshape"));

    var waveshape = \waveshape.kr(
        0.5,
        spec: ControlSpec(0, 1, \lin, 0, 0.5, "varshape")
    );

    var sync = \sync.kr(1, spec: ControlSpec(0, 1, \lin, 1, 1, "varshape"));

    var syncfreq = \syncfreq.ar(
        105,
        spec: ControlSpec(20, 20000, \exp, 0, 105, "varshape")
    );

    syncfreq = Select.ar(sync > 0.5, [freq, syncfreq]);
    sig = VarShapeOsc.ar(freq, pw, waveshape, sync, syncfreq);
    sig;
};
)