(
synth: {

    var numchannels = ~numchannels ?? 1;
    var buf = \buf.kr(0);
    var bufFrames = BufFrames.ir(buf);
    var bufdur = BufDur.ir(buf);
    var samplerate = BufSampleRate.ir(buf);
    var rate = \pitch.kr(spec: ControlSpec(-25, 25, \lin, 0, 0, "loop"));
    var startPos = \startPos.kr(spec:ControlSpec(0, 1, \lin, 0, 0, "loop")) * bufFrames;
    var endPos = \endPos.kr(spec:ControlSpec(0, 1, \lin, 0, 1, "loop")) * bufFrames;
    var start = startPos / samplerate;
    var dur = (endPos - startPos) / samplerate;
    var loopdur = Select.kr(dur < bufdur, [-1, dur]);
    var loop = \loop.kr(spec:ControlSpec(0, 1, \lin, 1, 1, "loop"));
    var ft = \cf.kr(spec:ControlSpec(0.001, 0.1, \lin, 0, 0.001, "loop"));
    var rev = {
        var rev = \rev.kr(0, spec:ControlSpec(0, 1, \lin, 1, 0, "loop"));
        Select.kr(rev > 0.5, [1, -1])
    };
    var trig = Changed.kr(start) + Changed.kr(loopdur);
    var sig = XPlayBuf.ar(numchannels.debug("numchannels"),
        bufnum: buf,
        rate: rate.midiratio * rev,
        trigger: trig,
        startPos: start,
        loopDur: loopdur,
        loop:loop,
        fadeTime:ft
    );
    sig!2
}
)
