/*
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
        rate: \playBackRate.kr(1),
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
    \tFreq, 200,
    \posRate, 0.5,
    \playBackRate, 1,
    \overlap, 0.5,
    \sndBuf, b,
    \amp, -5.dbamp,
    \out, 4
]);
)
x.set(\tFreq, 180, \overlap, 2, \posRate, 0.125, \playBackRate, 0.5)

x.free;
*/


(
var synth = {|freq|

    var sig;
    var numvoices = 5;
    var replyid = \bufposreplyid.kr(-1);
    var pan, grainamp, rate, detune, pos, durmod, phase;
    //var trig = CoinGate.ar(\prob.kr(1) , Impulse.ar( \grainrate.ar(20) ));
    var trig = numvoices.collect( { Impulse.ar( \grainrate.ar(20) *  (2 ** rrand(-1.0, 1.0))  )  } );

    var graindur = \graindur.kr(0.1);//LFNoise2.ar( 1!numvoices ).range(0.01, 0.5);
    var buf = \buf.kr;
    var bufdur = BufDur.kr(buf);
    var samplerate = BufSampleRate.kr(buf);
    var scale = BufRateScale.kr(buf);
    var start = bufdur * \startPos.kr(0);
    var end = bufdur * \endPos.kr(1);
    var dur = (end - start) * \pbstretch.kr(16);
    var voicespread = \voicespread.kr(1);

    pos = LFTri.ar(
        dur.reciprocal * scale * 0.5,
        iphase: 3
    );
    // add some slight randomness to the position
    pos = pos + LFNoise2.ar( \jitterrate.kr(0.1).dup(numvoices) ).bipolar(\jitterdepth.kr(0.01));
    // spread the positions of the voices
    pos = pos + Latch.kr( { voicespread.sum3rand }.dup(numvoices), Changed.kr(voicespread) + Impulse.kr(0) );
    pos = pos.clip(-1, 1).range(start, end);

    pan = PinkNoise.ar(1).range(-1.0, 1.0);
    grainamp = LFNoise2.ar(0.1.dup(numvoices)).range(0.5, 0.6);// * [1, 2, 0, 0, 0];
    rate = \rate.kr(1);
    detune = LFNoise2.kr(0.25.dup(numvoices)).bipolar(0.15).midiratio;

    sig = TGrains.ar(
        numChannels: 2,
        trigger: trig,
        bufnum: buf,
        rate: rate * detune,
        centerPos: pos,
        dur: graindur,
        pan: pan,
        amp: grainamp,
        interp:4
    );
   
    SendReply.kr(Impulse.kr(15), '/bufpos', [pos, grainamp], replyid + [0, 1]);
    sig = Splay.ar(sig, spread: 1);
    sig
};

(synth: synth)
)
