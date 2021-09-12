(
SynthDef(\reclooper, {
    var updateFreq = 15;
    var replyid = \bufposreplyid.kr(-1);
    var buf = \buf.kr(0);
    var out = \out.kr(0);
    var wet = \wet.kr(1);
    var in = In.ar(out, 2).asArray.sum;
    var frames = BufFrames.kr(buf);
    var rate = \rate.kr(1);
    var start = \startPos.kr(0) * frames;
    var end = \endPos.kr(1) * frames;
    var rec = \rec.kr(1);
    var phase = Phasor.ar(1, rate * BufRateScale.kr(buf), start, end);
    var fb = LocalIn.ar(1);
    var wr = BufWr.ar( (in * rec) + (fb * \fb.kr(0.7)), buf, phase, 1);
    var sig = BufRd.ar(1, buf, phase, 1, 4);
    sig = LeakDC.ar(sig);
    LocalOut.ar(sig);
    SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, phase], replyid);
    sig = sig.dup;
    wet = wet * EnvGate(i_level: 0, doneAction:2, curve:\sin);
    XOut.ar(out, wet, sig); 
}).add
)

