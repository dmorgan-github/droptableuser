(
Ndef(\o, {

	var n = 2;
	var buf = \buf.kr(0);
	var rate = \rate.kr(1).lag(1);
	var start = \startPos.kr(0);
	var end = \endPos.kr(1);
	var replyid = \bufposreplyid.kr(-1);
	var trig = \trig.tr(1);
	var ft = \ft.kr(0.1);
	var updateFreq = 10;
	var startPos = min(start, end) * BufFrames.kr(buf);
	var endPos = max(end, start) * BufFrames.kr(buf);

	var dur = ((endPos - startPos) / BufSampleRate.kr(buf)) * rate.reciprocal;
	var duty = TDuty.ar(dur.abs, trig, 1);
	var resetPos = Select.kr(rate > 0, [endPos, startPos] );
	var phase = Phasor.ar(duty, rate, startPos, endPos, resetPos);

	var index = Stepper.ar(duty, 0, 0, n-1);
	var gates = n.collect({|i|
		InRange.ar(index, i-0.5, i+0.5 );
	});
	var envs = Env.asr(
		attackTime:ft,
		sustainLevel:1,
		releaseTime:ft,
		curve:\wel
	).ar(gate:gates);

	var sig = PlayBuf.ar(numChannels:1, bufnum:buf, rate:rate, trigger:gates, startPos:resetPos);

	sig = sig * envs;
	sig = sig.sum;

	SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, phase % BufFrames.kr(buf)], replyid);
	Splay.ar(sig);
})
)