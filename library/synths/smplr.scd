(
var func = {arg numchannels = 2;

	var buf = \buf.kr(0);
	var numframes = BufFrames.kr(buf);
	var rate = \speed.kr(1);
	var start = \start.kr(0) * numframes;
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
	rate: ControlSpec(0.1, 4.0, \lin, 0, 1)
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
)