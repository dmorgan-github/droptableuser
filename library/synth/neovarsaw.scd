(
synth: {|freq, gate, aeg|
    var pw = \pw.kr(0.5, spec:ControlSpec(-1, 1, \lin, 0, 0.5, "neovarsaw"));
    var waveshape = \waveshape.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, "neovarsaw"));
    var sig = NeoVarSawOsc.ar(freq, pw, waveshape);
    sig;
},
doc: "
waveshape: Slope or notch. 0.0 to 1.0. 0 = notch, 1 = slope
"
)