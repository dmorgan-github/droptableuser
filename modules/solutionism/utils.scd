(
Ndef(\recbuf, {
	var in = \in.ar([0, 0]);
	var buf = \buf.kr;
	var trig = \trig.tr;
	var offset = \offset.kr(0);
	var recLevel = \reclevel.kr(1);
	var preLevel = \prelevel.kr(0);
	var run = \run.kr(0);
	var loop = \loop.kr(0);
	var sig = RecordBuf.ar(in, buf, offset, recLevel, preLevel, run, loop, trig);
	Splay.ar(sig);
})
)