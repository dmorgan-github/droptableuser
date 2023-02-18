(
synth: {|freq, gate|

    var numchannels = ~numchannels ?? {1};
    var updateFreq = 15;
    var root = \rootfreq.kr(60.0.midicps).clip(20, 20000);
    var replyid = \bufposreplyid.kr(-1);
    var buf = \buf.kr(0, spec:ControlSpec(units:"buf"));
    var numframes = max(BufFrames.kr(buf), 1);

    var start = \startPos.kr(0, spec: ControlSpec(0, 0.9999, \lin, 0, 0, units:"sampler"));
    var end = \endPos.kr(1, spec: ControlSpec(0, 1, \lin, 0, 1, units:"sampler") ).max(start);
    var pitched = \pitched.kr(0, spec:ControlSpec(0, 1, \lin, 1, 0, units:"sampler"));

    var rate = Select.kr(pitched, [
        \rate.kr(1, spec:ControlSpec(0.125, 4, \lin, 0, 1, "sampler")),
        freq/root
    ]);

    var dir = Select.kr(
        \rev.kr(0, spec:ControlSpec(0, 1, \lin, 1, 0, units:"sampler")) > 0.5,
        [1, -1]
    );

    var phase, sig;
    var sawrate = rate * BufSampleRate.kr(buf) / (absdif(start, end) * numframes);
    phase = (LFSaw.ar(sawrate * dir, 1)).range(start, end) * numframes;

    sig = BufRd.ar(
        numChannels: numchannels.debug("numchannels"),
        bufnum: buf,
        phase: phase,
        loop: 0,
        interpolation: 4 // cubic interpolation
    );

    SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, phase], replyid);

    sig;
}
)



