(
synth: {arg sig_in;

    var in = sig_in * \tapedelay_input.ar(1);
    var input = in.asArray.sum;
    var sig = LADSPA.ar(1, 1211,

        \tape_speed.ar(1),
        0.ampdb, //-70

        \tap1_distance.ar(1),
        \tap1_level.ar(1).ampdb,

        \tap2_distance.ar(2),
        \tap2_level.ar(0).ampdb,

        \tap3_distance.ar(3),
        \tap3_level.ar(0).ampdb,

        \tap4_distance.ar(4),
        \tap4_level.ar(0).ampdb,

        input
    );

    sig = in.blend(sig, \tapedelay_wet.kr(0.5));
    sig * \tapedelay_output.kr(1);
},
specs: [
    tape_speed: ControlSpec(0,10,\lin,0,1, units:"tapedelay"),
    tap1_distance: ControlSpec(0,4,\lin,0,1, units:"tapedelay"),
    tap1_level: ControlSpec(0,1,\lin,0,1, units:"tapedelay"),
    tap2_distance: ControlSpec(0,4,\lin,0,2, units:"tapedelay"),
    tap2_level: ControlSpec(0,1,\lin,0,0, units:"tapedelay"),
    tap3_distance: ControlSpec(0,4,\lin,0,3, units:"tapedelay"),
    tap3_level: ControlSpec(0,1,\lin,0,0, units:"tapedelay"),
    tap4_distance: ControlSpec(0,4,\lin,0,4, units:"tapedelay"),
    tap4_level: ControlSpec(0,1,\lin,0,0, units:"tapedelay"),
    tapedelay_input: ControlSpec(0, 2, \lin, 0, 1, units:"tapedelay;"),
    tapedelay_output: ControlSpec(0, 2, \lin, 0, 1, units: "tapedelay"),
    tapedelay_wet: ControlSpec(0, 1, \lin, 0, 0.5, units: "tapedelay")
]
)
