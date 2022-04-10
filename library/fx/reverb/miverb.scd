(
synth: {|in|
    var time = \miverb_time.kr(0.7, spec:ControlSpec(0, 1.25, \lin, 0, 0.7, "miverb"));
    var damp = \miverb_damp.kr(0.2, spec:ControlSpec(0, 1, \lin, 0, 0.2, "miverb"));
    var hp = \miverb_hp.kr(0.05, spec:ControlSpec(0, 1, \lin, 0, 0.05, "miverb"));
    var freeze = \miverb_freeze.kr(0, spec:ControlSpec(-1, 1, \lin, 0, 0, "miverb"));
    var sig = MiVerb.ar(LeakDC.ar(in), time, 1, damp, hp, freeze, 0.625);
    sig = in.blend(sig, \miverb_mix.kr(0.3, spec:ControlSpec(0, 1, \lin, 0, 0.3, "miverb")));
    sig;
}
)
