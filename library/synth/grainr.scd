(
synth: {
    var updateFreq = 15;
    var replyid = \bufposreplyid.kr(-1);
    var buf = \buf.kr(0);
    var start = \startPos.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, "grain"));
    var end = \endPos.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, "grain"));
    var envbuf = \envbuf.kr(-1);
    var bufFrames = BufFrames.ir(buf);
    var samplerate = BufSampleRate.ir(buf);
    var ratescale = BufRateScale.kr(buf);
    var seconds = ((end * bufFrames) - (start * bufFrames)) / samplerate;
    var prob = \prob.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, "grain"));
    var grainrate = \grainrate.ar(20, spec:ControlSpec(1/16, 220, \lin, 0, 20, "grain"));
    var trig = {
        var trig = SelectX.ar(
            \async.kr(0, spec: ControlSpec(0, 1, \lin, 0, 0, "grain")),
            [Impulse.ar(grainrate), Dust.ar(grainrate)]
        );
        CoinGate.ar(prob, trig)
    }.();

    var dur = [
        \graindurL.kr(0.1, spec: ControlSpec(0.01, 4, \lin, 0, 0.1, "grain")),
        \graindurR.kr(0.1, spec: ControlSpec(0.01, 4, \lin, 0, 0.1, "grain"))
    ];

    var rate = [
        \playbackrateL.kr(1, spec: ControlSpec(1/8, 4, \lin, 0, 1, "grain")),
        \playbackrateR.kr(1, spec: ControlSpec(1/8, 4, \lin, 0, 1, "grain"))
    ];

    var speed = [
        \phaserateL.kr(1, spec: ControlSpec(-10, 10, \lin, 0, 1, "grain")),
        \phaserateR.kr(1, spec: ControlSpec(-10, 10, \lin, 0, 1, "grain"))
    ] * ratescale;

    var dir = [
        Select.kr(\revL.kr(0, spec: ControlSpec(0, 1, \lin, 1, 0, "grain")), [1, -1]),
        Select.kr(\revR.kr(0, spec:ControlSpec(0, 1, \lin, 1, 0, "grain")), [1, -1])
    ];

    var phase = SelectX.ar(\pos.kr(0, spec: ControlSpec(0.0, 1, \lin, 0, 0, "grain")), [
        Phasor.ar(0, speed, start * bufFrames, end * bufFrames),
        LFDNoise3.ar(grainrate).range(start * bufFrames, end * bufFrames),
    ]);

    var grainamp = \grainamp.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, "grain"));

    var pan = \pan.kr(0 spec:ControlSpec(-1, 1, \lin, 0, 0, "grain"));

    var numgrains = dur/grainrate.reciprocal;

    var sig = GrainBufJ.ar(
        numChannels: 2,
        trigger: trig,
        dur: dur,
        sndbuf: buf,
        rate: rate * dir,
        pos: phase/bufFrames,
        interp: 2,
        grainAmp: grainamp,
        pan: pan,
        envbufnum: envbuf,
        maxGrains: 512,
    );

    sig = LeakDC.ar(sig);
    sig = sig * \amp.kr(-6.dbamp) * numgrains.reciprocal;
    SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, phase.asArray.wrapAt(0) ], replyid);
    sig
},
doc: "
winenv = Env([0, 1, 0], [0.5, 0.5], [8, -8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);
"
)