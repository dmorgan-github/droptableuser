/*
# 1408 Barry's Satan Maximiser
> k: Decay time (samples) (2 to 30)
> k: Knee point (dB) (-90 to 0)
> a: Input
< a: Output
*/
(
synth: {arg sig_in;

    var in = sig_in * \satan_input.ar(1);
    var sig = LADSPA.ar(1, 1408,
        \decay.ar(10).lag(0.01),
        [
            \kneepointL.ar(-30).lag(0.01),
            \kneepointR.ar(-30).lag(0.01)
        ],
        in
    );

    sig = in.blend(sig, \satan_mix.kr(0.5));

    sig = LeakDC.ar(sig) * 0.1;
    sig = sig * \satan_output.ar(1);
    sig;
},
specs: [
    decay: ControlSpec(2, 30, \lin, 0, 10, units:"fx"),
    kneepointL: ControlSpec(-90, 1, \lin, 0, -30, units:"fx"),
    kneepointR: ControlSpec(-90, 1, \lin, 0, -30, units:"fx"),
    satan_input: ControlSpec(0, 2, \lin, 0, 1, units:"vol"),
    satan_output: ControlSpec(0, 2, \lin, 0, 1, units: "vol"),
    satan_mix: ControlSpec(0, 1, \lin, 0, 0.5, units: "vol")
]
)