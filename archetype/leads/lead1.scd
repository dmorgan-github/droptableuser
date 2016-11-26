(
ProxySynthDef(\lead, {arg freq = 110, dur = 1,
	t_trig = 1;

	var freqlag = freq.lag(0.12);
	var env = Env.linen(sustainTime:dur).ar;
	var sig = SinOscFB.ar(freqlag * [1, 1.01], Rand(0.1, 0.5) );
	sig = sig.fold(-0.05, SinOsc.ar(0.05).range(0.1, 0.5) ).wrap(-0.5, 0.5);
	//sig = Squiz.ar(sig);
	sig = DFM1.ar(sig, XLine.ar(660, 2000, dur) );
	sig = sig + RLPF.ar(sig, XLine.ar(220, 880, dur), 0.05 );
	//sig = sig + BLowPass.ar(sig, 220);
	sig = JPverb.ar(sig.tanh);
	sig * env;
}).add;

)

Pdef(\lead).play(quant:0.0)

(
Pdef(\lead, Pbind(\instrument, \lead,
	\degree, Pseq([1, 1, 2, 1, 1, 2, 3, 2, 1, 1, 2, 3, 4, 3, 2, 1, 1, 2, 3, 4, 5, 4, 3, 2, 1, 1, 2, 3, 4, 3, 2, 1, 1, 2, 3, 2, 1, 1, 2, 1, 1] -1, inf),
	\octave, Pseq([3, 4], inf),
	\delta, 8,
	\scale, Scale.ritusen,
	\amp, 0.05,
	\dur, Pkey(\delta) * 1.3,
	\sustain, Pkey(\dur) * 4
))
)



