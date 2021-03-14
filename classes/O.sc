/*
Looper
*/
O : Device {

    /*
    var <phase;

    phase_ {|func|
    phase = func;
    this.prBuild;
    }

    deviceInit {
    // this will call rebuild
    this.phase_({arg dur, freq, duty, rate;
    LFSaw.ar(freq, 1);
    });
    }
    */

    deviceInit {

        this.put(0, {

            var updateFreq = 10;
            var replyid = \bufposreplyid.kr(-1);
            var buf = \buf.kr(0);
            var lag = \lag.kr(1);
            var rate = \rate.kr(1).lag(lag);
            var startPos = \startPos.kr(0).lag(0.01);
            var endPos = \endPos.kr(1).lag(0.01);

            var cuePos = \cuePos.kr(0);
            var trig = \trig.tr(0);

            var phase, sig;
            #sig, phase = LoopBufCF.ar(numChannels:1,
                bufnum:buf,
                rate:rate,
                trigger:trig,
                startPos:startPos,
                endPos:endPos,
                resetPos:cuePos,
                ft:\ft.kr(0.05));

            SendReply.kr(Impulse.kr(updateFreq), '/bufpos', [0, phase % BufFrames.kr(buf)], replyid);
            Splay.ar(sig, \spread.kr(1), center:\pan.kr(0)) * \amp.kr(1);
        });

        this.wakeUp;
    }

    view {
        ^U(\buf, this)
    }
}
