(
synth: {|freq, gate|
    var accent = \accent.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, "bd"));
    var tone = \tone.kr(0.8, spec:ControlSpec(0, 1, \lin, 0, 0.8, "bd"));
    var decay = \decay.kr(0.1, spec:ControlSpec(0, 1, \lin, 0, 0.1, "bd"));
    var attackfm = \attackfm.kr(0.1, spec:ControlSpec(0, 1, \lin, 0, 0.1, "bd"));
    var selffm = \selffm.kr(0.05, spec:ControlSpec(0, 1, \lin, 0, 0.05, "bd"));
    var sig = AnalogBassDrum.ar(gate, 0, accent, freq, tone, decay, attackfm, selffm);
    sig
}
)