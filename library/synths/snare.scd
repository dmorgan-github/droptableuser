(
synth: {|freq|

    var sig = AnalogSnareDrum.ar(
        Impulse.kr(0),
        infsustain: 0.0,
        accent: \accent.kr(0.1),
        freq: freq[0],
        tone: \tone.kr(0.5),
        decay: \dec.kr.max(0.001),
        snappy: \snappy.kr(0.5)
    );
    sig
},
specs: [
    accent: ControlSpec(0, 1, \lin, 0, 0.1, units: "timbre"),
    tone: ControlSpec(0, 1, \lin, 0, 0.5, units: "timbre"),
    snappy: ControlSpec(0, 1, \lin, 0, 0.5, units: "timbre")
]
)