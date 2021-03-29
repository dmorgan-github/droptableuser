/////////////////////////////////////////////////////////////////////
// buffer slicer
/////////////////////////////////////////////////////////////////////
//~buf = ~buf ?? Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
//~beats = nil;
//~numslices = 8;
(
Pdef(\slicer,
	Pbind(
		\instrument, \smplr_1chan,
		\buf, Pkey(\buf),
		\cf, 0.05,
		\dir, 1, //[-1, 1].prand,
		\bufdur, Pfunc({|evt|
			var buf = evt[\buf];
			buf.duration;
		}),
		\numslices, Pfunc({|evt|
			var num = evt[\numslices];
			if (num.isNil) {8}{num};
		}),
		\slicedur, Pkey(\numslices).reciprocal * Pkey(\bufdur),
		\slices, Pfunc({|evt|
			var numslices = evt[\numslices];
			(0..numslices-1)/numslices;
		}),
		\stretch, Pfunc({|evt|
			var len = evt[\beats];
			var bufdur = evt[\bufdur];
			var val = if (len.isNil) {1}{len/bufdur};
			val;
		}),
		\dur, Pkey(\slicedur),
		\speed, Pkey(\stretch).reciprocal,
		\sustain, Pkey(\dur) * Pkey(\stretch),
		\start, Plazy({|evt|
			var val = evt[\slices];
			Pseq(val, inf)
		}),
	)
)
)

