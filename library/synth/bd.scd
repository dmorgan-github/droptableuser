(
synth: {|freq|

    var sig = AnalogBassDrum.ar(
        Impulse.kr(0),
        infsustain: 0.0,
        accent: \accent.kr(0.1),
        freq: freq[0],
        tone: \tone.kr(0.5),
        decay: \dec.kr.max(0.001),
        attackfm: \attackfm.kr(0.5),
        selffm: \selffm.kr(0.25)
    );
    sig
},
specs: [
    accent: ControlSpec(0, 1, \lin, 0, 0.5, units: "timbre"),
    tone: ControlSpec(0, 1, \lin, 0, 0.5, units: "timbre"),
    attackfm: ControlSpec(0, 1, \lin, 0, 0.5, units: "timbre"),
    selffm: ControlSpec(0, 1, \lin, 0, 0.25, units: "timbre")
]
)