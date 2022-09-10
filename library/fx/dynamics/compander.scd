(
synth: {|in|
    var gain;
    var thresh = \comp_threshdb.kr(-20, spec:ControlSpec(-60, 0, \lin, 0, -20, units:"compander")).dbamp;
    var ratio = \comp_ratio.kr(2, spec:ControlSpec(1, 16, \lin, 0, 2, units:"compander")).reciprocal;
    var atk = \comp_atk.kr(0.005, spec:ControlSpec(0.001, 0.1, \lin, 0, 0.01, units:"compander"));
    var rel = \comp_rel.kr(0.1, spec:ControlSpec(0.1, 1, \lin, 0, 0.1, units:"compander"));
    var sig = Compander.ar(in, in, thresh, 1, ratio, atk, rel);
    //gain = 1/(((1.0-thresh) * ratio) + thresh); // make up
    //sig = sig * gain;
    sig = in.blend(sig, \comp_mix.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, units:"compander")));
    sig;
}
)