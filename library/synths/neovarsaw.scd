(
synth: {|freq, gate, aeg|
    var pw = \pw.kr(0.5, spec:ControlSpec(-1, 1, \lin, 0, 0.5, "timbre"));
    var waveshape = \waveshape.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, "timbre"));
    var sig = NeoVarSawOsc.ar(freq, pw, waveshape);
    sig;
}
)