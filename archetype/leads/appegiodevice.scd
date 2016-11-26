(
a = ~sawSignal.(513, 20);
b = Buffer.alloc(s, 1024, 1);
b.sendCollection(a.asWavetableNoWrap);
)

(
f = {arg freq = 220;
	Shaper.ar(b, SinOsc.ar(freq), Line.kr(1,12,6));
};

x = {arg freq = 220, gate = 1, dur = 0.5, amp = 1;
	var mod1 = SynthDef.wrap(f);
	var mod2 = (SinOsc.ar(freq, 0, Line.kr(1, 1.3, dur) ) + mod1);
	var osc = SinOsc.ar([freq, freq * LFNoise2.kr(1,0.01,1) ], mod2);
	Limiter.ar(Splay.ar(LeakDC.ar(osc)), 0.7) * EnvGen.kr(Env.linen(attackTime:0.1), gate:gate, timeScale:dur, doneAction:2) * amp;
};

Tdef(\main, {

	var freqs = 146.8323839587 * Scale.zhi.ratios.scramble.pyramid(4);
	var seq = Pseq(freqs, inf).asStream;

	inf.do({arg i;

		var freq = seq.next();
		x.play(args:[\freq, freq, \amp, rrand(0.1, 0.5), \dur, 0.5]);
		0.25.wait;
	});
}).play;

)