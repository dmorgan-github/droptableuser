(
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
)
