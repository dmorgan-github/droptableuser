(

synth: {
    var numchannels = ~numchannels.debug("numchannels") ?? 1;
    var buf = \buf.kr(0);
    var bufFrames = BufFrames.ir(buf);
    var bufdur = BufDur.ir(buf);
    var samplerate = BufSampleRate.ir(buf);
    var rate = \rate.kr(spec:ControlSpec(1/16, 4, \lin, 0, 1, "loop"));
    var startPos = \startPos.kr(spec:ControlSpec(0, 1, \lin, 0, 0, "loop")) * bufFrames;
    var endPos = \endPos.kr(spec:ControlSpec(0, 1, \lin, 0, 1, "loop")) * bufFrames;
    var start = startPos / samplerate;
    var dur = (endPos - startPos) / samplerate;
    var loopdur = Select.kr(dur < bufdur, [-1, dur]);
    var loop = \loop.kr(spec:ControlSpec(0, 1, \lin, 1, 1, "loop"));
    var ft = \cf.kr(spec:ControlSpec(0.001, 0.1, \lin, 0, 0.001, "loop"));
    var trig = Changed.kr(start) + Changed.kr(loopdur);
    var sig = XPlayBuf.ar(numchannels, buf, rate, trig, start, loopdur, loop:loop, fadeTime:ft);
    sig = Splay.ar(sig, \spread.kr(1), center:\pan.kr(0));
    sig * \amp.kr(-6.dbamp)
}
)
