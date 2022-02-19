(
synth: {|freq|

    var sig = AnalogBassDrum.ar(
        Impulse.kr(0),
        infsustain: 0.0,
        accent: \accent.kr(0.1, spec: ControlSpec(0, 1, \lin, 0, 0.5, units: "bd")),
        freq: freq[0],
        tone: \tone.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, units: "bd")),
        decay: \dec.kr.max(0.001),
        attackfm: \attackfm.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, units: "bd")),
        selffm: \selffm.kr(0.25, spec: ControlSpec(0, 1, \lin, 0, 0.25, units: "bd"))
    );
    sig
}
)