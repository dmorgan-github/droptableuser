LoopBufCF {

	/*
	*ar {|numChannels, bufnum=0, rate=1.0, trigger=1.0, startPos=0.0, endPos=1.0, ft=0.1|
		var n = 2;
		var start = startPos * BufFrames.kr(bufnum);
		var end = endPos * BufFrames.kr(bufnum);
		var dur = ((end - start) / BufSampleRate.kr(bufnum)) * rate.reciprocal;
		var duty = TDuty.ar(dur.abs, trigger, 1);
		var resetPos = Select.kr(rate > 0, [end, start]);
		var phase = Phasor.ar(duty, rate, start, end, resetPos);

		var index = Stepper.ar(duty, 0, 0, n-1);
		var gates = n.collect({|i|
			InRange.ar(index, i-0.5, i+0.5 )
		});
		var envs = Env.asr(
			attackTime:ft,
			sustainLevel:1,
			releaseTime:ft,
			curve:\wel
		).ar(gate:gates).sqrt;

		var sig = PlayBuf.ar(numChannels:1, bufnum:bufnum, rate:rate, trigger:gates, startPos:resetPos);

		sig = sig * envs;
		sig = sig.sum * \amp.kr(-6.dbamp);
		^[sig, phase];
	}
	*/

	*ar {|numChannels=1, bufnum=0, rate=1.0, trigger=1.0, startPos=0.0, endPos=1.0, ft=0.05|

		var n = 2;
		var start = startPos * BufFrames.kr(bufnum);
		var end = endPos * BufFrames.kr(bufnum);
		var phase = Phasor.ar(trigger, rate, start, end);
		var trig = 1-(phase > Delay1.ar(phase));

		var index = Stepper.ar(trig, 0, 0, n-1);
		var gates = n.collect({|i|
			InRange.ar(index, i-0.5, i+0.5);
		});

		var lag = 1/ft.asArray.wrapExtend(2);
		var envs = Slew.ar(gates, lag[0], lag[1]).sqrt;

		var phases = Phasor.ar(gates, rate, start, end + (SampleRate.ir * ft), start);
		var sig = BufRd.ar(numChannels, bufnum, phases, loop:0);
		sig = sig * envs;
		^[sig, phase];
	}
}