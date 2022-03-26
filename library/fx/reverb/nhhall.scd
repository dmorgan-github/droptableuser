(
synth: {|in|

    var sig = NHHall.ar(in,
        \rt60.ar(1, spec: ControlSpec(0.1, 60, \lin, 0.0, 1, units:"reverb") ).lag(0.1),
        \stereo.ar(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, units:"reverb")),
        \lowFreq.ar(200, spec:ControlSpec(20, 20000, \exp, 0, 200, units:"reverb")),
        \lowRatio.ar(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, units:"reverb")),
        \hiFreq.ar(4000, spec: ControlSpec(20, 20000, \exp, 0, 40000, units:"reverb")),
        \hiRatio.ar(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, units:"reverb")),
        \earlyDiffusion.ar(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, units:"reverb")),
        \lateDiffusion.ar(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, units:"reverb")),
        \modRate.ar(0.2, spec: ControlSpec(0, 1, \lin, 0, 0.2, units:"reverb")),
        \modDepth.ar(0.3, spec: ControlSpec(0,1,\lin, 0, 0.3, units:"reverb"))
    );

    sig = in.blend(sig, \nhhall_mix.kr(0.3, spec: ControlSpec(0, 1, \lin, 0, 0.3, "reverb")));
    sig;
}
)