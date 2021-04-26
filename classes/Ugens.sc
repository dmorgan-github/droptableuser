Modal {

    *ar {|freq, harm=0, bright=0.5, morph=0|

        var sig;
        var exciter;
        var k = (1..8);
        var ratio = {
            var val = k * (1 + ((k-1) * harm));
            val/val[0];
        }.();

        bright = bright.linlin(0, 1, 80, 8000);
        exciter = LPF.ar(Impulse.ar(0), bright);
        morph = morph.linlin(0, 1, 1, 100);

        sig = DynKlank.ar(`[
            ratio,
            (k * -3).dbamp,
            ratio.squared.reciprocal * 5;
        ], exciter, freq, decayscale: morph);

        ^sig;
    }
}


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

/*
# 1408 Barry's Satan Maximiser
> k: Decay time (samples) (2 to 30)
> k: Knee point (dB) (-90 to 0)
> a: Input
< a: Output
*/
Satan {

    *ar {|in, decay=10, kneepointL=(-30), kneepointR=(-30)|
        var sig = LADSPA.ar(1, 1408,
            decay,
            [
                kneepointL,
                kneepointR
            ],
            in
        );

        ^LeakDC.ar(sig);
    }
}

ReverseDelay {

    *ar {|in, delayL=1, delayR=1, feedbackL=(0.5), feedbackR=(0.5), crossfade=20|

        var sig = LADSPA.ar(1, 1605,
            in,
            [delayL, delayR],
            -60, // dry
            0, // wet
            [feedbackL, feedbackR],
            crossfade
        );

        ^sig;
    }
}
