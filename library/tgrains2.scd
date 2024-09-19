/*


https://scsynth.org/t/using-a-signal-window-as-an-envelop/8901/2?u=droptableuser
(
var multiChannelTrigger = { |numChannels, trig|
    numChannels.collect{ |chan|
        PulseDivider.ar(trig, numChannels, chan);
    };
};

var multiChannelPhase = { |triggers, windowRate|
    triggers.collect{ |localTrig, i|
        var hasTriggered = PulseCount.ar(localTrig) > 0;
        var localPhase = Sweep.ar(localTrig, windowRate * hasTriggered);
        localPhase * (localPhase < 1);
    };
};

var hanningWindow = { |phase|
    (1 - (phase * 2pi).cos) / 2 * (phase < 1);
};

SynthDef(\granular, { |sndBuf|

    var numChannels = 8;

    var tFreq, trig, windowRate, triggers, windowPhases, grainWindows, pos, sig;

    tFreq = \tFreq.kr(10);
    trig = Impulse.ar(tFreq);
    windowRate = tFreq / \overlap.kr(1);

    triggers = multiChannelTrigger.(numChannels, trig);
    windowPhases = multiChannelPhase.(triggers, windowRate);
    grainWindows = hanningWindow.(windowPhases);

    pos = Phasor.ar(
        trig: DC.ar(0),
        rate: \posRate.kr(1) * BufRateScale.kr(sndBuf) * SampleDur.ir / BufDur.kr(sndBuf),
        start: \posLo.kr(0),
        end: \posHi.kr(1)
    );

    sig = PlayBuf.ar(
        numChannels: 1,
        bufnum: sndBuf,
        rate: \playBackRate.kr(1) * BufRateScale.kr(sndBuf),
        trigger: triggers,
        startPos: pos * BufFrames.kr(sndBuf),
        loop: 1
    );

    sig = sig * grainWindows;

    sig = Pan2.ar(sig, \pan.kr(0));
    sig = sig.sum;

    sig = sig * \amp.kr(-10.dbamp);

    sig = LeakDC.ar(sig);
    OffsetOut.ar(\out.kr(0), sig);

}).add;
)

(
{
    var phase = Sweep.ar;
    IEnvGen.ar(Env([0, 1, 0], [0.5, 0.5], \sin), phase);
}.plot(1);
)


b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

(
x = Synth(\granular, [
    \tFreq, 1000,
    \overlap, 8,
    \sndBuf, b,
    \amp, -25.dbamp,
    \out, 4
]);
)

x.free;

(
x = Synth(\granular, [
    \tFreq, 1,
    \posRate, 0.75,
    \playBackRate, 0.25,
    \overlap, 8,
    \sndBuf, B.grain5,
    \amp, -5.dbamp,
    \out, 4
]);
)

x.set(\sndBuf, Ndef(\t1_buf) )
x.set(\sndBuf, B.grain2 )
x.set(\posRate, 1, \tFreq, 10, \playBackRate, 1, \amp, -20.dbamp, \posLo, 0.3, \posHi, 0.7, \overlap, 8)
x.free

*/
(
var func = {|freq|
	
    var dur, phase, pan, grainamp, sig, trig;
    var updateFreq = 15;
    var replyid = \bufposreplyid.kr(-1);
    var buf = \buf.kr(spec:ControlSpec(units:"buf"));

    var bufdur = BufDur.kr(buf);
    var numframes = BufFrames.kr(buf);
    var samplerate = BufSampleRate.kr(buf);// * SampleRate.ir.poll;

    var root = \rootfreq.kr(60.0.midicps,
        spec:ControlSpec(20, 20000, \exp, 0, 60.0.midicps, units:"tgrains")
    ).clip(20, 20000);

    var pitched = \pitched.kr(0, spec:ControlSpec(0, 1, \lin, 1, 0, units:"tgrains"));
    var pitch = \pitch.kr(1, spec: ControlSpec(-24.midiratio, 24.midiratio, \lin, 0, 0.midiratio, units:"tgrains"));

    var rate = Select.kr(pitched, [
        pitch,
        (freq ?? root)/root
    ]);

    var grainrate = \grainrate.ar(20, spec: ControlSpec(1/16, 80, \lin, 0, 20, units:"tgrains"));
    var trigperiod;
    var stretch = \pbstretch.kr(1, spec:ControlSpec(1, 100, \lin, 0, 1, units:"tgrains"));

    trigperiod = grainrate.reciprocal;
    dur = \graindur.kr(0.2, spec: ControlSpec(1/128, 1, \lin, 0, 0.2, units:"tgrains"));
    grainamp = 1 * (1.1 ** LFNoise2.ar( {rrand(1.0, 2.0)}.dup(2) ) );
    dur = dur + LFNoise2.ar( { rrand(1.0, 2.0) }.dup(2)  ).unipolar(0.05);

    trig = {
        var prob = \prob.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units:"tgrains"));
        var async = \async.kr(0, spec: ControlSpec(0, 1, \lin, 0, 0, units:"tgrains"));
        var trig = SelectX.ar(
            async,
            [Impulse.ar(grainrate), Dust.ar(grainrate)]
        );
        CoinGate.ar(prob, trig);
    }.value;

    phase = {
        var start = \startPos.kr(0, spec: ControlSpec(0, 1-0.9999, \lin, 0, 0, units:"buf"));
        var end = \endPos.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units:"buf"));
        var startPos = bufdur * start;
        var endPos = bufdur * end;
        var dur = endPos - startPos;
        LFSaw.ar((dur * stretch).reciprocal, iphase: 1).linlin(-1, 1, startPos, endPos);
    }.value;

    sig = TGrains.ar(
        numChannels:1,
        trigger:trig,
        bufnum:buf,
        rate:rate,
        centerPos: phase * ( 1.02 ** LFNoise2.ar( {rrand(1.0, 2.0)}.dup(2) ) ),
        dur: dur,
        pan:[-1, 1],
        amp: grainamp.clip(0, 1),
        interp:4
    );

    sig[1] = DelayC.ar(sig[1], trigperiod/2, trigperiod/2);
    sig = HPF.ar(sig, 80);

    SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, phase * samplerate], replyid);
    sig = Splay.ar(sig, 1) * 0.5;
    sig;
};

(func: func)
)