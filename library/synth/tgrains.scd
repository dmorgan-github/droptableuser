(
synth: {|freq|

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

    var trig = {
        var grainrate = \grainrate.ar(20, spec: ControlSpec(1/16, 80, \lin, 0, 20, units:"tgrains"));
        var prob = \prob.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units:"tgrains"));
        var async = \async.kr(0, spec: ControlSpec(0, 1, \lin, 0, 0, units:"tgrains"));
        var trig = SelectX.ar(
            async,
            [Impulse.ar(grainrate), Dust.ar(grainrate)]
        );
        CoinGate.ar(prob, trig)
    };

    var dur = \graindur.kr(0.1, spec: ControlSpec(1/128, 1, \lin, 0, 0.1, units:"tgrains"));

    var phase = {
        //var pos = \center.kr(0, spec: ControlSpec(0, 1, \lin, 0, 0, "grain"));
        var start = \startPos.kr(0, spec: ControlSpec(0, 1, \lin, 0, 0, units:"tgrains"));
        var end = \endPos.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units:"tgrains"));
        var bufdur = BufDur.kr(buf);
        var startPos = bufdur * start;
        var endPos = bufdur * end;
        var dur = endPos - startPos;
        var stretch = \pbstretch.kr(1, spec:ControlSpec(-100, 100, \lin, 0, 1, units:"tgrains"));
        stretch = stretch + 0.000001; // avoid divide by zero
        LFSaw.ar((dur * stretch).reciprocal).range(startPos, endPos)
    };

    var pan = {
        var pan = 0;//\grainpan.kr(0, spec: ControlSpec(-1, 1, \lin, 0, 0, "grain"));
        var panHz = \grainpanLfoHz.kr(0.1, spec: ControlSpec(0, 1, \lin, 0, 0.1, units:"tgrains"));
        var panRand = \grainpanLfoDepth.kr(0.5, spec: ControlSpec(0, 1, \lin, 0, 0.5, units:"tgrains"));
        pan = pan + LFNoise1.kr(panHz).bipolar(panRand);
        pan.clip(-1, 1);
    };

    var grainamp = {
        var amp = 1;//\grainamp.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, "grain"));
        var ampHz = \grainampLfoHz.kr(0.1, spec: ControlSpec(0, 1, \lin, 0, 0.1, units:"tgrains"));
        var ampRand = \grainampLfoDepth.kr(0, spec: ControlSpec(0, 1, \lin, 0, 0, units:"tgrains"));
        amp = amp + LFNoise1.kr(ampHz).bipolar(ampRand);
        amp.clip(0, 1);
    };

    var sig = TGrains.ar(
        numChannels:2,
        trigger:trig.(),
        bufnum:buf,
        rate:rate,
        centerPos:phase.(),
        dur:dur,
        pan:pan.(),
        amp:grainamp.(),
        interp:4
    );

    sig = sig;// * \amp.kr;//(-6.dbamp);
    sig;
}
)