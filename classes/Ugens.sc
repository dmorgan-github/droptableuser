LoopBufCF {

    *ar {|numChannels=1, bufnum=0, rate=1.0, trigger=0.0, startPos=0.0, endPos=1.0, resetPos=0.0, ft=0.05|
        var n = 2;
        var start = startPos * BufFrames.kr(bufnum);
        var end = endPos * BufFrames.kr(bufnum);
        var bufratescale = BufRateScale.kr(bufnum);
        var reset = Select.kr(trigger, [start, resetPos * BufFrames.kr(bufnum)]);
        var phase = Phasor.ar(trigger, rate * bufratescale, start, end, reset);
        var trig = Trig1.ar(1-(phase < Delay1.ar(phase)), ControlDur.ir) + trigger;

        var index = Stepper.ar(trig, 0, 0, n-1);
        var gates = n.collect({|i|
            InRange.ar(index, i-0.5, i+0.5);
        });

        var lag = 1/ft.asArray.wrapExtend(2);
        var envs = Slew.ar(gates, lag[0], lag[1]).sqrt;

        var cfphases = Phasor.ar(gates,
            rate * bufratescale,
            start,
            end + (BufSampleRate.kr(bufnum) * ft),
            reset
        );
        var sig = BufRd.ar(numChannels, bufnum, cfphases, loop:0);

        sig = sig * envs;
        ^[sig.sum!2, phase];
    }
}
