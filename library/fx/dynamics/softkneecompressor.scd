(
synth: {|in|
    var thresh = \comp_threshdb.kr(-20, spec:ControlSpec(-60, 0, \lin, 0, -20, units:"compressor"));
    var ratio = \comp_ratio.kr(2, spec:ControlSpec(1, 16, \lin, 0, 2, units:"compressor"));
    var atk = \comp_atk.kr(0.01, spec:ControlSpec(0.001, 0.1, \lin, 0, 0.01, units:"compressor"));
    var rel = \comp_rel.kr(0.1, spec:ControlSpec(0.1, 1, \lin, 0, 0.1, units:"compressor"));
    var knee = \comp_knee.kr(6, spec:ControlSpec(1, 20, \lin, 0, 6, "compressor"));
    var sig = SoftKneeCompressor.ar(in, in, thresh, ratio.reciprocal, knee, atk, rel);
    sig = in.blend(sig, \comp_mix.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, units:"compressor")));
    sig;
}
)