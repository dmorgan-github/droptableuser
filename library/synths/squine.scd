(
synth: {|freq|
    var clip = \clip.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, units:"wave"));
    var skew = \skew.kr(0, spec:ControlSpec(-1, 1, \lin, 0, 0, units:"wave"));
    var sync = \sync.kr(0, spec: ControlSpec(0, 2000, \lin, 0, 0, "wave"));
    var sig = Squine.ar(freq, clip, skew, sync);
    sig;
}
)