(
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
)