(
synth: {|freq|

    var numvoices = ~numvoices ?? 3;

    var updateFreq = 15;

    var replyid = \bufposreplyid.kr(-1);

    var buf = \buf.kr;

    var root = \rootfreq.kr(60.0.midicps,
        spec:ControlSpec(20, 20000, \exp, 0, 60.0.midicps, units:"tgrains")
    ).clip(20, 20000);

    var pitched = \pitched.kr(0, spec:ControlSpec(0, 1, \lin, 1, 0, units:"tgrains"));

    var pitch = \pitch.kr(1, spec: ControlSpec(-24.midiratio, 24.midiratio, \lin, 0, 0.midiratio, units:"tgrains"));

    var rate = Select.kr(pitched, [
        pitch,
        (freq ?? root)/root
    ]);

    var dur = \graindur.kr(0.1, spec: ControlSpec(1/128, 1, \lin, 0, 0.1, units:"tgrains"));

    var bufdur = BufDur.kr(buf);
    var numframes = BufFrames.kr(buf);
    var samplerate = BufSampleRate.kr(buf);// * SampleRate.ir.poll;
    var phase, trig, pan, grainamp, sig, pos;

    trig = {
        var grainrate = \grainrate.ar(20, spec: ControlSpec(1/16, 80, \lin, 0, 20, units:"tgrains"));
        var prob = \prob.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units:"tgrains"));
        var async = \async.kr(0, spec: ControlSpec(0, 1, \lin, 0, 0, units:"tgrains"));
        var trig = SelectX.ar(
            async,
            [Impulse.ar(grainrate), Dust.ar(grainrate)]
        );
        CoinGate.ar(prob, trig)
    }.();


    phase = {
        //var pos = \center.kr(0, spec: ControlSpec(0, 1, \lin, 0, 0, "grain"));
        var stretch = \pbstretch.kr(1, spec:ControlSpec(-100, 100, \lin, 0, 1, units:"tgrains"));
        var start = \startPos.kr(0, spec: ControlSpec(0, 1-0.9999, \lin, 0, 0, units:"tgrains"));
        var end = \endPos.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units:"tgrains"));
        var endPos = bufdur * end;
        var startPos = bufdur * start;// + LFNoise2.ar(1!2).range(0, 0.2);
        var dur = endPos - startPos;
        var changed = Changed.kr(startPos);
        stretch = stretch + ControlDur.ir; // avoid divide by zero

        //LFSaw.ar((dur * stretch).reciprocal, -1).range(startPos, endPos);

        /*
        Phasor.ar(
        changed + Impulse.ar(0),
        (BufRateScale.kr(buf)/SampleRate.ir) * stretch.reciprocal,
        startPos,
        endPos,
        { TRand.ar(startPos, endPos, changed + Impulse.ar(0)) }.dup(3)
        )
        */

        Phasor.ar(
            Impulse.ar(0),
            (BufRateScale.kr(buf)/BufSampleRate.kr(buf)) * stretch.reciprocal,
            startPos,
            endPos
        ) + { (LFNoise1.ar(1).bipolar(0.01) * dur).mod(dur) }.dup(numvoices.debug("numvoices"))

    };

    pan = {
        var pan = 0;//\grainpan.kr(0, spec: ControlSpec(-1, 1, \lin, 0, 0, "grain"));
        var panHz = \grainpanLfoHz.kr(0.1, spec: ControlSpec(0, 1, \lin, 0, 0.1, units:"tgrains"));
        var panRand = \grainpanLfoDepth.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, units:"tgrains"));
        pan = pan + LFNoise1.kr(panHz).bipolar(panRand);
        pan.clip(-1, 1);
    };

    grainamp = {
        var amp = 1;//\grainamp.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, "grain"));
        var ampHz = \grainampLfoHz.kr(0.1, spec: ControlSpec(0, 1, \lin, 0, 0.1, units:"tgrains"));
        var ampRand = \grainampLfoDepth.kr(0, spec: ControlSpec(0, 1, \lin, 0, 0, units:"tgrains"));
        amp = amp + LFNoise1.kr(ampHz).bipolar(ampRand);
        amp.clip(0, 1);
    };

    pos = phase.();

    sig = TGrains.ar(
        numChannels:1,
        trigger:trig,
        bufnum:buf,
        rate:rate,
        //https://scsynth.org/t/grainbuf-tgrains-timing-accuracy-and-sampling-rate/5793/5?u=droptableuser
        centerPos: pos, // + (dur * 0.5),
        dur:dur, //* [0.9, 0.99, 1.01, 1.1].scramble * LFNoise2.ar(1).range(0.99, 1.01),
        pan:pan.(),
        amp:grainamp.(),
        interp:4
    );

    SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, pos * samplerate], replyid);

    Splay.ar(sig.asArray.flatten);
}
)