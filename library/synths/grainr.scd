(

/*
winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);
*/
synth: {
    var updateFreq = 15;
    var replyid = \bufposreplyid.kr(-1);
    var buf = \buf.kr(0);
    var start = \startPos.kr(0);
    var end = \endPos.kr(1);
    var envbuf = \envbuf.kr(-1);
    var bufFrames = BufFrames.ir(buf);
    var samplerate = BufSampleRate.ir(buf);
    var ratescale = BufRateScale.kr(buf);
    var seconds = ((end * bufFrames) - (start * bufFrames)) / samplerate;
    var prob = \prob.kr(1);
    var grainrate = \grainrate.ar(20);
    var trig = {
        var trig = SelectX.ar(\async.kr(0), [Impulse.ar(grainrate), Dust.ar(grainrate)]);
        CoinGate.ar(prob, trig)
    }.();
    var dur = [\graindurL.kr(0.1), \graindurR.kr(0.1)]; //SinOsc.kr(0.15).range(0.1, 1);
    var rate = [\playbackrateL.kr(1), \playbackrateR.kr(1)] * ratescale;
    var speed = [\phaserateL.kr(1), \phaserateR.kr(1)] * ratescale;
    var dir = [Select.kr(\revL.kr(0), [1, -1]), Select.kr(\revR.kr(0), [1, -1])];
    //var phase = LFSaw.ar(seconds.reciprocal * speed, -1).linlin(-1, 1, start, end) ;
    var phase = Phasor.ar(0, speed, start * bufFrames, end * bufFrames);
    var sig = GrainBuf.ar(
        numChannels: 2,
        trigger: trig,
        dur: dur,
        sndbuf: buf,
        rate: rate * dir,
        pos: phase/bufFrames,
        interp: 2,
        pan: 0,
        envbufnum: envbuf,
        maxGrains: 512,
    );

    sig = LeakDC.ar(sig);
    sig = sig * \amp.kr(-6.dbamp);
    sig = Splay.ar(sig.flatten, spread:\spread.kr(1), center:\pan.kr(0));
    SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, phase.asArray.wrapAt(0) ], replyid);
    //sig = Rotate2.ar(sig[0], sig[1], LFSaw.kr(\rotaterate.kr(1/8)));
    sig
},
specs: [
    grainrate: ControlSpec(1/16, 80, \lin, 0, 20, "grain"),
    startPos: ControlSpec(0, 1, \lin, 0, 0, "grain"),
    endPos: ControlSpec(0, 1, \lin, 0, 1, "grain"),
    prob: ControlSpec(0, 1, \lin, 0, 1, "grain"),
    playbackrateL: ControlSpec(1/8, 4, \lin, 0, 1, "grain"),
    playbackrateR: ControlSpec(1/8, 4, \lin, 0, 1, "grain"),
    phaserateL: ControlSpec(1/8, 4, \lin, 0, 1, "grain"),
    phaserateR: ControlSpec(1/8, 4, \lin, 0, 1, "grain"),
    async: ControlSpec(0, 1, \lin, 1, 0, "grain"),
    revL: ControlSpec(0, 1, \lin, 1, 0, "grain"),
    revR: ControlSpec(0, 1, \lin, 1, 0, "grain"),
    rotaterate: ControlSpec(1/8, 20, \lin, 9, 1/8, "stereo"),
    graindurL: ControlSpec(0.01, 1, \lin, 0, 0.1, "grain"),
    graindurR: ControlSpec(0.01, 1, \lin, 0, 0.1, "grain")
]
)