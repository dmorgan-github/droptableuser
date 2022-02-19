(
synth: {|freq|

    var sig;
    var pw = \pw.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, "wave"));

    var waveshape = \waveshape.kr(
        0.5,
        spec: ControlSpec(0, 1, \lin, 0, 0.5, "wave")
    );

    var sync = \sync.kr(1, spec: ControlSpec(0, 1, \lin, 1, 1, "wave"));

    var syncfreq = \syncfreq.ar(
        105,
        spec: ControlSpec(20, 20000, \exp, 0, 105, "wave")
    );

    // there is a weird interation between this and rings
    // something getting corrupted between the two
    // resulting in low frequency clicks
    syncfreq = Select.ar(sync > 0.5, [freq, syncfreq]);

    sig = VarShapeOsc.ar(freq, pw, waveshape, sync, syncfreq);
    sig;
};
)