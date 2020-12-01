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


(
Ndef(\o6, {

	var n = 2;
	var updateFreq = 10;
	var replyid = \bufposreplyid.kr(-1);
	var buf = \buf.kr(0);
	var rate = \rate.kr(1);//MouseX.kr(-0.5, 2);
	var ft = \ft.kr(0.05);
	var start = \startPos.kr(0.1) * BufFrames.kr(buf);
	var end = \endPos.kr(0.9) * BufFrames.kr(buf);
	var phase = Phasor.ar(1, rate, start, end);
	var trig = 1-(phase > Delay1.ar(phase));

	var index = Stepper.ar(trig, 0, 0, n-1);
	var gates = n.collect({|i|
		InRange.ar(index, i-0.5, i+0.5 );
	});

	var lag = 1/ft.asArray.wrapExtend(2);
	var envs = Slew.ar(gates, lag[0], lag[1]).sqrt;

	var phases = Phasor.ar(gates, rate, start, end + (SampleRate.ir * ft), start);
	var sig = BufRd.ar(1, buf, phases, loop:0);
	//var sig = PlayBuf.ar(1, buf, rate, gates, start, end);

	sig = sig * envs;

	//sig[0].poll(label:\a);
	//sig[1].poll(label:\b);

	SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, phase % BufFrames.kr(buf)], replyid);

	Splay.ar(sig);
})
)