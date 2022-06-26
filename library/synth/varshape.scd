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
},
doc: "
pw: Pulse width when shape is square. Saw, ramp, tri otherwise. 0.0 to 1.0
waveshape: Blend between waveshapes. 0.0 is saw/ramp/tri and 1.0 is square
sync: Whether or not to sync oscillator. 1.0 turns sync on. 0.0 is off
syncfreq: Sync oscillator frequency in herz
"
)