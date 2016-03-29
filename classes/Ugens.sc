Stutter {

/*
"http://sccode.org/1-50T"
Example Usage:
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
// audio-rate stutter inspired by DestroyFX
(
{
	var snd, holdperiod, multiplier;
	snd = PlayBuf.ar(1, b, BufRateScale.kr(b), loop: 1);
	holdperiod = MouseY.kr(0.01, 1.0, 1);
	multiplier = MouseX.kr(1, 20);
	snd = Stutter.ar(snd, Impulse.ar(holdperiod.reciprocal), holdperiod / multiplier);
	snd * 0.3!2;
}.play;
)
*/
    *ar {arg in, reset, length, rate = 1.0, maxdelay = 10;

        var phase, fragment, del;
        phase = Sweep.ar(reset);
        fragment = {arg ph; (ph - Delay1.ar(ph)) < 0 + Impulse.ar(0) }.value(phase / length % 1);
        del = Latch.ar(phase, fragment) + ((length - Sweep.ar(fragment)) * (rate - 1));
		/*
		This seems close but not exact and I can't really understand why.
		It's easier to understand but perhaps not complete...
		del = Demand.ar(Impulse.ar(fragmentlength.reciprocal), reset, Dseries(0, fragmentlength, inf) );
		*/
        ^DelayC.ar(in, maxdelay, del);
    }
}

// DelayC.ar(snd, 1.0, LFNoise0.ar(13).range(0.0, 1.0));