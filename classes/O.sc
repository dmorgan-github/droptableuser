/*
Looper
*/
O : D {

    var <phase;

    phase_ {|func|
        phase = func;
        this.prBuild;
    }

    deviceInit {
        this.prBuild
    }

    prBuild {

		var func = this.phase;

		this.put(0, {

            var numChannels = 1;
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

            if (func.isNil) {
                #sig, phase = LoopBufCF.ar(numChannels:1,
                    bufnum:buf,
                    rate:rate,
                    trigger:trig,
                    startPos:startPos,
                    endPos:endPos,
                    resetPos:cuePos,
                    ft:\ft.kr(0.05)
                );
            } {
                var start = startPos * BufFrames.kr(buf);
                var end = endPos * BufFrames.kr(buf);
                var dur = ((end - start) / BufSampleRate.kr(buf)) * rate.abs.reciprocal;
                phase = func.(dur, dur.reciprocal);
                phase = phase.range(start, end);
                sig = BufRd.ar(numChannels, buf, phase, loop:0);
           };

            SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, phase % BufFrames.kr(buf)], replyid);
            sig = LeakDC.ar(sig);
            sig = Splay.ar(sig, \spread.kr(1), center:\pan.kr(0));
            sig = sig * \amp.kr(1);
            sig;
		});

		this.wakeUp;
	}

    view {|index|
       //super.view(index);
       U(\buf, this)
    }
}
