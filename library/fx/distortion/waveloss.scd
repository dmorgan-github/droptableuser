(
synth: {arg in;

    var mix = \waveloss_mix.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, "waveloss"));
    var sig = WaveLoss.ar(in,
        \drop.ar(20, spec: ControlSpec(1,50,\lin,1,20, units:"waveloss")),
        \outof.ar(40, spec:ControlSpec(1,100,\lin,1,40, units:"waveloss")),
        \mode.ar(1, spec: ControlSpec(1,2,\lin,1,1, units:"waveloss")),
    );
    sig = LeakDC.ar(sig);
    sig = in.blend(sig, mix);
    sig
}
)