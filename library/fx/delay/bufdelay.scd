(
synth: {|in|
    var updateFreq = 15;
    var replyid = \bufposreplyid.kr(-1);
    var buf = \buf.kr(0);
    var sig_in = in.asArray.sum;//In.ar(out, 2).asArray.sum;
    var frames = BufFrames.kr(buf);
    var rate = \rate.kr(1, spec: ControlSpec(0.0625, 4, \lin, 0, 1, units:"bufdelay"));
    var start = \startPos.kr(0, spec: ControlSpec(0, 1, \lin, 0, 0, units:"bufdelay")) * frames;
    var end = \endPos.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units:"bufdelay")) * frames;
    var rec = \rec.kr(1, spec:ControlSpec(0, 1, \lin, 1, 0, "bufdelay"));
    var phase = Phasor.ar(1, rate * BufRateScale.kr(buf), start, end);
    var fb = SafetyLimiter.ar(LocalIn.ar(1)) * \fb.kr(0.7, spec:ControlSpec(0, 1, \lin, 0, 0.7, "bufdelay"));
    var wr = BufWr.ar( (sig_in * rec) + (fb), buf, phase, 1);
    var sig = BufRd.ar(1, buf, phase, 1, 4);
    sig = LeakDC.ar(sig);
    LocalOut.ar(sig);
    SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, phase], replyid);
    sig = sig.dup;
    sig;
}
)