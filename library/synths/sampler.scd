(
synth: {|freq, gate|

    var updateFreq = 15;
    var root = \rootfreq.kr(60.0.midicps,
        spec:ControlSpec(20, 20000, \exp, 0, 60.0.midicps)
    ).clip(20, 20000);
    var replyid = \bufposreplyid.kr(-1);
    var buf = \buf.kr(0);
    var numframes = BufFrames.kr(buf);
    var start = \startPos.kr(0);
    var end = \endPos.kr(1).max(start);
    var pitched = \pitched.kr(0, spec:ControlSpec(0, 1, \lin, 1, 0));
    var rate = Select.kr(pitched, [
        \rate.kr(1),
        freq/root
    ]);

    var dir = Select.kr(\dir.kr < 0.5, [1, -1]);
    var phase = dir * Phasor.ar(rate: rate * BufRateScale.kr(buf), start:numframes * start, end:numframes * end);
    var numchannels = ~numchannels ?? {1};

    var sig = BufRd.ar(
        numChannels: numchannels.debug("numchannels"),
		bufnum: buf,
		phase: phase,
		interpolation: 4
	);

    SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, phase], replyid);

    sig;
}
)