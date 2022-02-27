(
synth: {|in|

    var sig = JPverb.ar(in,
        t60:\t60.kr(1, spec:ControlSpec(0.1, 60, \lin, 0.0, 1, units:"jpverb")).lag(0.1),
        damp:\damp.kr(0, spec:ControlSpec(0, 1, \lin, 0.0, 0, units:"jpverb")),
        size:\size.kr(1, spec:ControlSpec(0.5, 5, \lin, 0, 1, units:"jpverb")).lag(0.1),
        earlyDiff:\earlyDiff.kr(0.707, spec:ControlSpec(0, 1, \lin, 0, 0.707, units:"jpverb")),
        modDepth:\modDepth.kr(0.1, spec:ControlSpec(0, 1, \lin, 0, 0.1, units:"jpverb")),
        modFreq:\modFreq.kr(2, spec:ControlSpec(0, 10, \lin, 0, 2, units:"jpverb")),
        low:\low.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, units:"jpverb")),
        mid:\mid.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, units:"jpverb")),
        high:\high.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, units:"jpverb")),
        lowcut:\lowcut.kr(500, spec:ControlSpec(100, 6000, \exp, 1, 500, units:"jpverb")),
        highcut:\highcut.kr(2000, spec:ControlSpec(1000, 10000, \exp, 1, 2000, units:"jpverb"))
    );

    sig = in.blend(sig, \jpverb_mix.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, "jpverb")));
    sig;
}
)