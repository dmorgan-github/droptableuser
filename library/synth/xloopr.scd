(
synth: {
    var numChannels = ~numchannels ?? 1;
    var updateFreq = 15;
    var replyid = \bufposreplyid.kr(-1);
    var buf = \buf.kr(0);
    var lag = \lag.kr(1);
    var rate = \rate.kr(1, spec:ControlSpec(0.125, 4, \lin, 0, 1, "xloopr")).lag(lag);

    var startPos = \startPos.kr(0, spec: ControlSpec(0, 0.9999, \lin, 0, 0, units:"xloopr")).lag(0.01);///.poll(label:\startPos);
    var endPos = \endPos.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units:"xloopr") ).max(startPos).lag(0.01);
    var rev = Select.kr(\rev.kr(0, spec:ControlSpec(0, 1, \lin, 1, 0, "xloopr")), [1, -1]);

    var cuePos = \cuePos.kr(0);
    var trig = \trig.tr(0);
    var phase, sig, aeg;
    var dir = ~dir ?? 0;
    var func = ~func;

    func = switch(dir.debug("dir"),
        1, {
            {|dur, rate|
                LFTri.ar(rate * 0.5, -1)
            }
        },
        {func}
    );

    if (func.isNil) {
        #sig, phase = LoopBufCF.ar(numChannels:1,
            bufnum:buf,
            rate:rate * rev,
            trigger:trig,
            startPos:startPos,
            endPos:endPos,
            resetPos:cuePos,
            ft:\ft.kr(0.05)
        );
    } {
        var start = startPos * BufFrames.kr(buf);
        var end = endPos * BufFrames.kr(buf);
        var dur = ((end - start) / BufSampleRate.kr(buf)) * rate.abs.reciprocal;
        phase = func.(dur, dur.reciprocal);
        phase = phase.range(start, end);
        sig = BufRd.ar(numChannels, buf, phase, loop:0);
        sig = sig!2;
    };

    SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, phase % BufFrames.kr(buf)], replyid);
    sig;
}
)
