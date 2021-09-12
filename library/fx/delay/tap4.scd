(
synth: {arg sig_in;

    var in = sig_in * \input.ar(1);
    var tap1, tap2, tap3, tap4;
    var fbNode = FbNode(1, 6.5, 4);

    var tap1_delay = \tap1_delay.ar(2).lag(0.1)/16;
    var tap2_delay = \tap2_delay.ar(6).lag(0.1)/16;
    var tap3_delay = \tap3_delay.ar(10).lag(0.1)/16;
    var tap4_delay = \tap4_delay.ar(16).lag(0.1)/16;

    var tap1_mul = \tap1_mul.ar(1).lag(0.1);
    var tap2_mul = \tap2_mul.ar(0.7).lag(0.1);
    var tap3_mul = \tap3_mul.ar(0.5).lag(0.1);
    var tap4_mul = \tap4_mul.ar(0.2).lag(0.1);

    tap1 = fbNode.delay(tap1_delay);
    tap2 = fbNode.delay(tap2_delay);
    tap3 = fbNode.delay(tap3_delay);
    tap4 = fbNode.delay(tap4_delay);

    fbNode.write(Mix.ar(in)
        + (tap1 * \tap1_fb.ar(0).lag(0.1))
        + (tap2 * \tap2_fb.ar(0).lag(0.1))
        + (tap3 * \tap3_fb.ar(0).lag(0.1))
        + (tap4 * \tap4_fb.ar(0).lag(0.1))
    );

    Splay.ar([tap1 * tap1_mul, tap2 * tap2_mul, tap3 * tap3_mul, tap4 * tap4_mul],
        \spread.ar(1),
        center:\pan.ar(0)
    ) * \output.ar(1);
},
specs: [

    tap1_delay: ControlSpec(1, 32, \lin, 1, 2, units:"tap1"),
    tap2_delay: ControlSpec(1, 32, \lin, 1, 6, units:"tap2"),
    tap3_delay: ControlSpec(1, 32, \lin, 1, 10, units:"tap3"),
    tap4_delay: ControlSpec(1, 32, \lin, 1, 16, units:"tap4"),

    tap1_mul: ControlSpec(0, 1, \lin, 0, 1, units:"tap1"),
    tap2_mul: ControlSpec(0, 1, \lin, 0, 0.7, units:"tap2"),
    tap3_mul: ControlSpec(0, 1, \lin, 0, 0.5, units:"tap3"),
    tap4_mul: ControlSpec(0, 1, \lin, 0, 0.2, units:"tap4"),

    tap1_fb: ControlSpec(0, 1, \lin, 0, 0, units:"tap1"),
    tap2_fb: ControlSpec(0, 1, \lin, 0, 0, units:"tap2"),
    tap3_fb: ControlSpec(0, 1, \lin, 0, 0, units:"tap3"),
    tap4_fb: ControlSpec(0, 1, \lin, 0, 0, units:"tap4"),

    spread: ControlSpec(0, 1, \lin, 0, 1, units:"stereo"),
    pan: ControlSpec(-1, 1, \lin, 0, 0, units:"stereo"),
    input: ControlSpec(0, 2, \lin, 0, 1, units:"vol"),
    output: ControlSpec(0, 2, \lin, 0, 1, units: "vol")
]
)