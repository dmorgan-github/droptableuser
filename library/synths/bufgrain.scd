(
synth: {

    var updateFreq = 15;
    var replyid = \bufposreplyid.kr(-1);
    var buf = \buf.kr(0);
    var freq = \freq.ar(20);
    var rate = \rate.ar(1);
    var overlap = \overlap.ar(2);
    var sig, env;
    var bufFrames = BufFrames.ir(buf);
    var trig, phase, dur, dir;

    var freqLfo = {
        var freqLfoHz = \freqLfoHz.kr(0);
        var freqLfoDepth = \freqLfoDepth.kr(0);
        SinOsc.ar(freqLfoHz, Rand(0.0,2pi)) * freqLfoDepth;
    };

    var rateLfo = {
        var rateLfoHz = \rateLfoHz.kr(0);
        var rateLfoDepth = \rateLfoDepth.kr(0);
        SinOsc.ar(rateLfoHz, Rand(0.0,2pi)) * rateLfoDepth;
    };

    var grainRate = {
        var pulse = Impulse.ar(freq.lag(0.05));
        var dust = Dust.ar(freq.lag(0.05));
        var async = \async.kr(0);
        var trig = SelectX.ar(async, [pulse, dust]);
        trig;
    };

    var phasor = {

        var speedLfoHz = \speedLfoHz.kr(0);
        var speedLfoDepth = \speedLfoDepth.kr(0);
        var speedLfo = { SinOsc.ar(speedLfoHz, Rand(0.0,2pi)) * speedLfoDepth; };

        var startLfoHz = \startLfoHz.kr(0);
        var startLfoDepth = \startLfoDepth.kr(0);
        var startLfo = { SinOsc.ar(startLfoHz, Rand(0.0,2pi)) * startLfoDepth; };

        var endLfoHz = \endLfoHz.kr(0);
        var endLfoDepth = \endLfoDepth.kr(0);
        var endLfo = { SinOsc.ar(endLfoHz, Rand(0.0,2pi)) * endLfoDepth; };

        var speed = \speed.ar(1) + speedLfo.dup;
        var start = \startPos.kr(0) + startLfo.dup;
        var end = \endPos.kr(1) + endLfo.dup;

        Phasor.ar(
            trig: 0.0,
            rate: speed * BufRateScale.kr(buf),
            start: start * bufFrames,
            end: end * bufFrames,
            resetPos: 0.0
        );
    };

    var grainDur = {
        var default = freq.reciprocal;

        var grainDurLfo = {
            var grainDurLfoHz = \grainDurLfoHz.kr(0);
            var grainDurLfoDepth = \grainDurLfoDepth.kr(0);
            SinOsc.ar(grainDurLfoHz, Rand(0.0,2pi)) * grainDurLfoDepth;
        };
        var dur = \grainDur.kr(0) + grainDurLfo.dup;
        var which = dur > 0;
        Select.kr(which, [default, dur]).max(0) * overlap;
    };

    var rev = {|trig|
        var revprob = \revprob.kr(0);
        Demand.kr(A2K.kr(trig), 0, Dwrand([-1, 1], [revprob, 1-revprob], inf));
    };

    var prob = \prob.kr(1);

    freq = freq + freqLfo.dup;
    rate = rate + rateLfo.dup;
    trig = grainRate.();
    phase = phasor.();
    dur = grainDur.();
    dir = rev.(trig);

    sig = GrainBuf.ar(
        numChannels: 1,
        trigger: CoinGate.ar(prob, trig),
        dur: dur,
        sndbuf: buf,
        rate: rate * dir,
        pos: phase / bufFrames,
        interp: 2,
        pan: 0,
        envbufnum: -1,
        maxGrains: 512,
    );

    SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, phase], replyid);
    sig;
}, 

specs: [
    overlap: [1, 24, \lin, 1, 12].asSpec,
    speed: [0, 1, \lin, 0, 1].asSpec,
    speedLfoHz: [0.0, 20, \lin, 0, 0].asSpec,
    speedLfoDepth: [0.0, 4, \lin, 0, 0].asSpec,
    rate: [0.01, 4, \lin, 0, 1].asSpec,
    rateLfoHz: [0.0, 20, \lin, 0, 0].asSpec,
    rateLfoDepth: [0.0, 4, \lin, 0, 0].asSpec,
    grainDur: [0.0, 4, \lin, 0, 0.0].asSpec,
    grainDurLfoHz: [0.0, 20, \lin, 0, 0].asSpec,
    grainDurLfoDepth: [0.0, 4, \lin, 0, 0].asSpec,
    async: [0, 1, \lin, 1, 0].asSpec,
    revprob: [0, 1, \lin, 0, 0].asSpec,
    prob: [0, 1, \lin, 0, 1].asSpec,
    freq: [0.01, 20, \lin, 0, 20].asSpec,
    freqLfoHz: [0.0, 20, \lin, 0, 0].asSpec,
    freqLfoDepth: [0.0, 4, \lin, 0, 0].asSpec
]

)
