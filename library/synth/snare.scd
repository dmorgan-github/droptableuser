(
synth: {|freq|

    var sig = AnalogSnareDrum.ar(
        Impulse.kr(0),
        infsustain: 0.0,
        accent: \accent.kr(0.1, spec: ControlSpec(0, 1, \lin, 0, 0.1, units: "snare")),
        freq: freq[0],
        tone: \tone.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, units: "snare")),
        decay: \snaredec.kr.max(0.001, ControlSpec(0, 1, \lin, 0, 0.001, units: "snare")),
        snappy: \snappy.kr(0.5, ControlSpec(0, 1, \lin, 0, 0.5, units: "snare"))
    );
    sig
}
)