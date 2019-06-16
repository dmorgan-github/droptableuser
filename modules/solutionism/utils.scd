(
Ndef(\recbuf_m, {
	var in = \in.ar([0, 0]).asArray.sum;
	var buf = \buf.kr;
	var trig = \trig.tr;
	var offset = \offset.kr(0);
	var recLevel = \reclevel.kr(1);
	var preLevel = \prelevel.kr(0);
	var run = \run.kr(0);
	var loop = \loop.kr(0);
	var sig = RecordBuf.ar(in, buf, offset:offset, recLevel:recLevel, preLevel:preLevel, run:run, loop:loop, trigger:trig);
	DC.kr(0);
});

Ndef(\recbuf_s, {
	var in = \in.ar([0, 0]);
	var buf = \buf.kr;
	var trig = \trig.tr;
	var offset = \offset.kr(0);
	var recLevel = \reclevel.kr(1);
	var preLevel = \prelevel.kr(0);
	var run = \run.kr(0);
	var loop = \loop.kr(0);
	var sig = RecordBuf.ar(in, buf, offset:offset, recLevel:recLevel, preLevel:preLevel, run:run, loop:loop, trigger:trig);
	DC.kr(0);
});
)