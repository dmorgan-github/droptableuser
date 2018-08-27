~p[\bufplay].mold;
(~p[\bufplay][0] = {

	var in = \in.ar([0,0]);

	var buf = LocalBuf(s.sampleRate * 10, 1).clear;

	var foo = {

		var rec = \rec.kr(1);
		var renv = Env.asr.kr(gate:rec);
		var penv = Env.asr.kr(gate:rec) * \plevel.kr(0);

		RecordBuf.ar(Mix.ar(in),
			buf,
			recLevel:renv,
			preLevel:penv,
			run:rec,
			loop:\rec_loop.kr(0),
			trigger:\rec_trig.kr(1)
		);
	}.();

	var pos = \pos.kr(0) * BufFrames.kr(buf);
	var trig = \trig.tr;
	var loop = \loop.kr(1);
	var sig = PlayBufCF.ar(1, buf, rate:\rate.kr(1), trigger:trig, startPos:pos, loop:loop);
	Pan2.ar(sig, \pan.kr(0));
});
)
~p[\bufplay].set(\rec_loop, 1, \rec, 1, \plevel, 0.7, \rate, -0.5, \pos, 0, \trig, 0, \loop, 1)
~p[\bufplay].play;
~p[\bufplay].stop;