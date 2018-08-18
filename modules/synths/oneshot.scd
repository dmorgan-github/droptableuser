(
SynthDef(\oneshot, {

	var buf = \buf.kr(0);
	var rate = \rate.kr(1);
	var sig = PlayBuf.ar(1, buf, rate, loop:0, doneAction:2);
	sig = Pan2.ar(sig, \pan.kr(0)) * \amp.kr(0.1);

	OffsetOut.ar(\out.kr(0), sig);

}).add;

)