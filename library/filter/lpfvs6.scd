(
synth:{|in, gate, freq, aeg|

    var cutoff = \cutoff.kr(1000, spec: ControlSpec(20, 20000, \exp, 0, 1000, "filter"));
    var slope = \slope.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, "filter"));
    var sig = LPFVS6.ar(in, cutoff.clip(20, 20000), slope);
    sig = sig * \fcomp.kr(1, spec: ControlSpec(1, 8, \lin, 0, 1, "filter"));
    sig;
}
)