(
synth: {|freq|

    var sig;
    var updateFreq = 15;
    var replyid = \bufposreplyid.kr(-1);

    var buf = \buf.kr(0);
    var bufdur = BufDur.kr(buf);
    var numframes = BufFrames.kr(buf);
    var samplerate = BufSampleRate.kr(buf);// * SampleRate.ir.poll;
    var bufratescale = BufRateScale.kr(buf);

    var start = \startPos.kr(0, spec: ControlSpec(0, 0.9999, \lin, 0, 0, units:"grainbuf"));
    var end = \endPos.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units:"grainbuf") ).max(start);

    var grainrate = \grainrate.kr(20, spec: ControlSpec(1/16, 80, \lin, 0, 20, units:"grainbuf"));
    var trig = Impulse.ar(grainrate);
    var pos = TRand.ar(start, end, trig);
    var root = \rootfreq.kr(60.0.midicps).clip(20, 20000);
    var pitched = \pitched.kr(0, spec:ControlSpec(0, 1, \lin, 1, 0, units:"grainbuf"));
    var rate = Select.kr(pitched, [
        \rate.kr(1, spec:ControlSpec(0.125, 4, \lin, 0, 1, "grainbuf")),
        freq/root
    ]);

    var dur = \graindur.kr(0.1, spec: ControlSpec(1/128, 1, \lin, 0, 0.1, units:"grainbuf"));
    var pan = \grainpan.kr(0, spec:ControlSpec(-1, 1, \lin, 0, 0, units:"grainbuf"));
    var grainamp = \grainamp.kr(1) * WhiteNoise.kr().range(0.5, 1.0);
    var envbuf = -1;

    sig = GrainBufJ.ar(
        numChannels:1, 
        trigger: trig, 
        dur: dur, 
        sndbuf: buf, 
        rate: rate * bufratescale, 
        pos: pos, 
        loop: 0, 
        interp: 4, 
        grainAmp: grainamp, 
        pan: pan, 
        envbufnum: envbuf
    );

    SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, pos * numframes], replyid);

    sig;
}
)
