(
synth: {|in|
    var thresh = \comp_threshdb.kr(-20, spec:ControlSpec(-60, 0, \lin, 0, -20, units:"compander"));
    var ratio = \comp_ratio.kr(2. spec:ControlSpec(1, 16, \lin, 0, 2, units:"compander"));
    var atk = \comp_atk.kr(0.01, spec:ControlSpec(0.001, 0.1, \lin, 0, 0.01, units:"compander"));
    var rel = \comp_rel.kr(0.1, spec:ControlSpec(0.1, 1, \lin, 0, 0.1, units:"compander"));
    var sig = Compander.ar(in, in, thresh.dbamp, 1, ratio, atk, rel);
    sig = in.mix(1, \comp_mix.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, units:"compander")));
    sig;
}
)