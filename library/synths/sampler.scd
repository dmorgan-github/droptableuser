(
var func = {arg numchannels = 2;

	var buf = \buf.kr(0);
	var numframes = BufFrames.kr(buf);
	var rate = \rate.kr(1);
	var start = \startPos.kr(0) * numframes;
	var len = \sustain.kr(0);
	var dir = \dir.kr(1);
	var loop = \loop.kr(0);
	var cf = \cf.kr(0.01);
	var sig = PlayBuf.ar(numchannels, buf, BufRateScale.kr(buf) * rate * dir, 1, start, loop:loop);
	var fullDur = BufFrames.kr(buf) * BufSampleRate.kr(buf).reciprocal;
	var dur = Select.kr(len > 0, [fullDur, len]);
	var aeg = Env.linen(cf, dur, cf).ar(gate:1, doneAction:Done.freeSelf);

	sig = LeakDC.ar(sig);
	sig = sig * aeg * \amp.kr(0.3) * \vel.kr(1);
	sig = Splay.ar(sig, \spread.kr(0), center:\center.kr(0));
	Out.ar(\out.kr(0), sig);
};

var specs = (
	start: ControlSpec(0, 1, \lin, 0, 0),
);

SynthDef(\smplr_2chan, {
	func.(2)
}, metadata: (
	specs: specs
)).add;

SynthDef(\smplr_1chan, {
	func.(1)
}, metadata: (
	specs: specs
)).add;

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

/////////////////////////////////////////////
//
SynthDef(\oneshot1, {
	var buf = \buf.kr(0);
	var rate = \rate.kr(1);
	var dir = \dir.kr(1);
	var start = \start.kr(0);
	var sig = PlayBuf.ar(1, buf, rate * dir, 1, startPos:start, loop:0, doneAction:Done.freeSelf);
	sig = sig * \amp.kr(-3.dbamp) * \vel.kr(1);
	sig = sig.softclip;
	sig = Splay.ar(sig, spread:\spread.kr(1), center:\pan.kr(0));
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\oneshot2, {
	var buf = \buf.kr(0);
	var rate = \rate.kr(1);
	var dir = \dir.kr(1);
	var start = \start.kr(0);
	var sig = PlayBuf.ar(2, buf, rate * dir, 1, startPos:start, loop:0, doneAction:Done.freeSelf);
	sig = sig * \amp.kr(-3.dbamp) * \vel.kr(1);
	sig = sig.softclip;
	sig = Splay.ar(sig, spread:\spread.kr(1), center:\pan.kr(0));
	Out.ar(\out.kr(0), sig);
}).add;

/////////////////////////////////////////////
//
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

    var aeg = Env.asr(
        \atk.kr(0.01),
        \suslevel.kr(1),
        \rel.kr(0.1),
        curve:\curve.kr(-4)
    ).ar(gate:gate, doneAction:Done.freeSelf);

	var sig = BufRd.ar(
		numChannels: 2,
		bufnum: buf,
		phase: phase,
		interpolation: 4
	);

	sig = LeakDC.ar(sig);
    sig = sig * aeg * \amp.kr(0.3) * \vel.kr(1);
    sig = Splay.ar(sig, spread:\spread.kr(1), center:\pan.kr(0));
    SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, phase], replyid);
    Out.ar(\out.kr(0), sig);

}).add;
)
