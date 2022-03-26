(
synth: {arg in;

    var input = in.asArray.sum;
    var sig = LADSPA.ar(1, 1211,

        \tape_speed.ar(1, spec:ControlSpec(0,10,\lin,0,1, units:"tapedelay")).lag(0.05),
        0.ampdb, //-70

        // distance is "inches"
        \tap1_distance.ar(1, spec:ControlSpec(0,4,\lin,0,1, units:"tapedelay")).lag(0.05),
        \tap1_level.ar(1, spec:ControlSpec(0,1,\lin,0,1, units:"tapedelay")).ampdb,

        \tap2_distance.ar(2, spec:ControlSpec(0,4,\lin,0,2, units:"tapedelay")).lag(0.05),
        \tap2_level.ar(0, spec:ControlSpec(0,1,\lin,0,0, units:"tapedelay")).ampdb,

        \tap3_distance.ar(3, spec:ControlSpec(0,4,\lin,0,3, units:"tapedelay")).lag(0.05),
        \tap3_level.ar(0, spec:ControlSpec(0,1,\lin,0,0, units:"tapedelay")).ampdb,

        \tap4_distance.ar(4, spec: ControlSpec(0,4,\lin,0,4, units:"tapedelay")).lag(0.05),
        \tap4_level.ar(0, spec:ControlSpec(0,1,\lin,0,0, units:"tapedelay")).ampdb,

        input
    );

    sig = in.blend(sig, \tapedelay_mix.kr(0.3, spec:ControlSpec(0, 1, \lin, 0, 0.3, units: "tapedelay")));
    sig;
}
)
