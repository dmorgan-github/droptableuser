/*
# 1408 Barry's Satan Maximiser
> k: Decay time (samples) (2 to 30)
> k: Knee point (dB) (-90 to 0)
> a: Input
< a: Output
*/
(
synth: {arg in;

    var sig = LADSPA.ar(1, 1408,
        \decay.ar(10, spec: ControlSpec(2, 30, \lin, 0, 10, units:"satan")).lag(0.01),
        [
            \kneepointL.ar(-30, spec: ControlSpec(-90, 1, \lin, 0, -30, units:"satan")).lag(0.01),
            \kneepointR.ar(-30, spec: ControlSpec(-90, 1, \lin, 0, -30, units:"satan")).lag(0.01)
        ],
        in
    );

    sig = in.blend(sig, \satan_mix.kr(0.3, spec: ControlSpec(0, 1, \lin, 0, 0.3, units: "satan")));
    sig = LeakDC.ar(sig);
    sig;// * \satan_out.kr(0.1, spec: ControlSpec(0, 1, \lin, 0, 0.1, units:"satan"));
}
)