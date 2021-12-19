/*
p = NodeProxy.audio(s, 2);

(p.prime({ arg rate = 1, amp = 0.3, bufnum = 0, t_trig = 1, phafps = 4, interp = 2;
	var framidx = Phasor.ar(t_trig, rate * BufRateScale.kr(bufnum), 0, inf);
	var playgen = BufRd.ar(2, bufnum, framidx, 0, interp);
	var done = framidx >= BufFrames.kr(bufnum);
	var env = 1 - done; // could add nicer fade out
	SendTrig.ar(env * Impulse.ar(phafps, 0.5), 66, framidx);
	SendTrig.ar(done, 77);
	env * playgen * amp}))

(o = OSCdef(\track, { arg msg, time;
	switch (msg[2])
	{66} {
		{ ("OSC now playing frame" + msg[3]).postln;}.defer }
	{77} {
		{ ("OSC buffer play ended.").postln }.defer;
		{ p.set(\t_trig, 1); ("OSC buffer play restarted").postln }.defer(3) }
}, '/tr', s.addr))

p.play.edit
*/

(
/////////////////////////////////////////////
//
SynthDef(\loopr, {

	var updateFreq = 15;
	var replyid = \bufposreplyid.kr(-1);
	var buf = \buf.kr(0);
	var lag = \lag.kr(1);
	var rate = \rate.kr(1).lag(lag);
	var startPos = \startPos.kr(0).lag(0.01);///.poll(label:\startPos);
	var endPos = \endPos.kr(1).lag(0.01);

	var cuePos = \cuePos.kr(0);
	var trig = \trig.tr(0);
	var phase, sig, aeg;

	#sig, phase = LoopBufCF.ar(numChannels:1,
		bufnum:buf,
		rate:rate,
		trigger:trig,
		startPos:startPos,
		endPos:endPos,
		resetPos:cuePos,
		ft:\ft.kr(0.05));

	aeg = Env.asr(
		\atk.kr(0.01),
		\suslevel.kr(1),
		\rel.kr(1.0),
		\curve.kr(-4)
	).ar(doneAction:Done.freeSelf, gate:\gate.kr(1));

	SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, phase % BufFrames.kr(buf)], replyid);

	sig = Splay.ar(sig, \spread.kr(1), center:\pan.kr(0));

	sig = sig * aeg * \amp.kr(1);

	Out.ar(\out.kr(0), sig);

}).add;

/////////////////////////////////////////////
// bi directional looper
SynthDef(\loopr2, {

	var numChannels = 1;
	var updateFreq = 15;
	var replyid = \bufposreplyid.kr(-1);
	var buf = \buf.kr(0);
	var lag = \lag.kr(1);
	var rate = \rate.kr(1).lag(lag);
	var startPos = \startPos.kr(0).lag(0.01);///.poll(label:\startPos);
	var endPos = \endPos.kr(1).lag(0.01);
	var aeg;

	var start = startPos * BufFrames.kr(buf);
	var end = endPos * BufFrames.kr(buf);
	var dur = ((end - start) / BufSampleRate.kr(buf)) * rate.abs.reciprocal;
	var phase = LFTri.ar(dur.reciprocal * 0.5, -1).range(start, end);
	var sig = BufRd.ar(numChannels, buf, phase, loop:0);

	aeg = Env.asr(
		\atk.kr(0.01),
		\suslevel.kr(1),
		\rel.kr(1.0),
		\curve.kr(-4)
	).ar(doneAction:Done.freeSelf, gate:\gate.kr(1));

	SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, phase % BufFrames.kr(buf)], replyid);

	sig = Splay.ar(sig, \spread.kr(1), center:\pan.kr(0));

	sig = sig * aeg * \amp.kr(1);

	Out.ar(\out.kr(0), sig);

}).add;

SynthDef(\sampler, {

    var updateFreq = 15;
    var replyid = \bufposreplyid.kr(-1);
    var buf = \buf.kr(0);
    var gate = \gate.kr(1);
    var numframes = BufFrames.kr(buf);
    var start = \startPos.kr(0);
    var end = \endPos.kr(1).max(start);
    var rate = \rate.kr(1) * BufRateScale.kr(buf);
    var dir = \dir.kr(1);
    var phase = dir * Phasor.ar(rate: rate, start:numframes * start, end:numframes * end);

    var adsr = {
        var atk = \atk.kr(0.01);
        var dec = \dec.kr(0.1);
        var rel = \rel.kr(0.1);
        var suslevel = \suslevel.kr(0.7);
        var ts = \ts.kr(1);
        var curve = [\atkcurve.kr(-4), \deccurve.kr(-4), \relcurve.kr(-4)];//\curve.kr(-4);
        var env = Env.adsr(
            attackTime:atk,
            decayTime:dec,
            sustainLevel:suslevel,
            releaseTime:rel,
            curve:curve
        );
        var aeg = env.ar(doneAction:Done.freeSelf, gate:gate, timeScale:ts);
        aeg;
    };

	var sig = BufRd.ar(
		numChannels: 1,
		bufnum: buf,
		phase: phase,
		interpolation: 4
	);

	sig = LeakDC.ar(sig);
    sig = sig * adsr.() * \amp.kr(-10.dbamp) * \vel.kr(1);
    sig = Splay.ar(sig);
    SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, phase], replyid);
    Out.ar(\out.kr(0), sig);

}, metadata: (
    env: \adsr
)).add;

)



