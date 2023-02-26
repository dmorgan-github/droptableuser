(
synth: {|freq, gate|
    var f = freq.asArray[0];
    var accent = \accent.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, "bd"));
    var tone = \tone.kr(0.8, spec:ControlSpec(0, 1, \lin, 0, 0.8, "bd"));
    var decay = \decay.kr(0.1, spec:ControlSpec(0, 1, \lin, 0, 0.1, "bd"));
    var attackfm = \attackfm.kr(0.1, spec:ControlSpec(0, 1, \lin, 0, 0.1, "bd"));
    var selffm = \selffm.kr(0.05, spec:ControlSpec(0, 1, \lin, 0, 0.05, "bd"));
    var sig = AnalogBassDrum.ar(gate, 0, accent, f, tone, decay, attackfm, selffm);
    sig * \gain.kr(1, spec:ControlSpec( 1, 2, \lin, 0, 1, "bd" ) )
},
presets: [
    (
        accent: 0,
        attackfm: 0.01, 
        decay: 0.1,
        selffm: 0.05,
        tone: 0.2
    )
]
)
