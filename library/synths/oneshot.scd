(
synth: {
	var buf = \buf.kr(0);
	var numframes = BufFrames.kr(buf);
	var rate = \rate.kr(1);
	var start = \startPos.kr(0) * numframes;
	var dir = Select.kr(\rev.kr(0) > 0.5, [1, -1]);
	var sig = PlayBuf.ar(1, buf, BufRateScale.kr(buf) * rate * dir, 1, start, loop:0, doneAction:Done.freeSelf);
    sig;
},
specs: [
    rev: [0, 1, \lin, 1, 0].asSpec
]
)
