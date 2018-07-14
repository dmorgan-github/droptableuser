~p2 = ProxySpace.new(s);
~p2.quant = 4.0;
(~p2[\snd][0] = {

	var trig = \trig.tr;

	var freq = Vibrato.ar(K2A.ar(\freq.kr(432).lag(\lag.kr(0.0))),
		\vrate.kr(6),
		\vdepth.kr(0.0),
		\vdelay.kr(0),
		\vonset.kr(0),
		\vrateVar.kr(0.04),
		\vdepthVar.kr(0.1)
	);

	var freqs = [freq.cpsmidi, freq.cpsmidi - 5].midicps;

	//var sig = Mix.fill(4,{
	//	//between 1 +- 0.01
	//	var freqmult = 1 + SinOsc.ar(LFNoise1.kr(rrand(0.25,0.5),4,5), pi.rand,0.01);
	//	SinOscFB.ar(freqs * (freqmult), 0.4.rand);// + Saw.ar(freq ) + PMOsc.ar(freq, freq * 2.1, 3, mul:0.06)
	//});

	var sig = SinOscFB.ar(freqs, 0.4.rand);

	var atk = \atk.kr(2);
	var sus = \sus.kr(2);
	var rel = \rel.kr(1);
	var curve = \curve.kr(4);
	var env = Env.linen(atk,sus,rel, curve:curve).kr(doneAction:0, gate:trig, timeScale:1, mul:1);

	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(0.1);

	//2.do({arg i;
	//	//sig = BLowPass.ar(sig, SinOsc.kr(2.4.reciprocal * 1/8).range(880, 2200), 0.5);
	//	sig = BLowPass.ar(sig, 2200, 0.4);
	//});

	sig = Pan2.ar(sig, \pan.kr(0));

	sig;
})


TempoClock.default.tempo_(25/60)
TempoClock.default.beatDur

/*
Random tip: (signal * preamp).tanh / (preamp ** 0.6) roughly compensates for the increase in gain when cranking up the distortion. Not tested for extreme values of preamp -- +/- 20 dB or 0.1 .. 10 seems pretty much OK.
*/

(~p2[\snd][2] = \set -> Pbind(

	\trig, 1,
	\isRest, false,//Pstep(Pseq([false, true], inf), Pseq([1.5, 0.5, 3.5, 0.5], inf) * Pstep(Pseq([1, 2, 4, 8]), Pseq([8, 16, 32, 64], inf), inf), inf),
	\delta, Pseq([16], inf),
	\beatDur, Pfunc({thisThread.clock.beatDur}),
	\dur, 1,//Pkey(\delta) * Pkey(\beatDur),
	\atk, Pkey(\dur) * 0.01,//Pstep(Pseq([0.001, 0.01, 0.1, 0.5, 1], inf), Pseq([2,4,8,18], inf), inf),//0.001,
	\sus, Pkey(\dur) * 0.1,//Pstep(Pseq([0.3,0.5,0.7], inf), Pseq([16,8,4,2],inf), inf),//0.7,
	\rel, Pkey(\dur) * 0.1,
	\scale, Scale.ritusen,
	\degree, Ppatlace([Pseq([0, 6, 0, 7, 0, 8, 0, 9],  inf), Pseq([1,3,2,4], inf)], inf),
	\mtranspose, Pstep(Pseq([0,1,2,-1], inf), Pseq([8,4,2], inf), inf),
	\octave, 6,
	\vdepth, 0.01,
	\amp, 0.3 * Ppatlace([ Pseq([1, 0.5], inf), Pseq([0.3,0.6,0.4], inf) ], inf),// Pseq([1, 0.3], inf)//0.2
	\lag, 0.0
))

(
~p2[\snd].filter(4, {arg in;

	var preamp = 5;

	var sig = (in * preamp).tanh / (preamp ** 0.6);

	sig;

}).set(\wet4, 0)
)

(~p2[\snd].filter(6, {arg in;

	var sig = in;

	var freqs, ringtimes;

    //freqs = [800, 1071, 1153, 1723] * MouseX.kr(0.5, 2, 1);

    //ringtimes = [1, 1, 1, 1] * MouseY.kr(0.1, 10, 1);

	sig = DelayC.ar( (sig.softclip * 3).softclip/(3**0.6), 0.3, 0.3);

	sig = HPF.ar(sig, 880);

	//sig = Resonz.ar(sig, 880, 0.2);

	//sig = sig + ( DynKlank.ar(`[freqs, nil, ringtimes ], sig) * 0.005);

	sig = sig + AllpassC.ar(sig, 2.4 * 0.75 * 2, 2.4 * 0.75 * 2, decaytime: 2.4 * 8, mul:1);

	sig;

}).set(\wet6, 0.2)
)


(~p2[\snd].filter(7, {arg in;

	/*
	# 1767 C* ChorusI - Mono chorus/flanger
	> a: in (-1 to 1)
	> k: t (ms) (2.5 to 40)
	> k: width (ms) (0.5 to 10)
	> k: rate (Hz) (0 to 5)
	> k: blend (0 to 1)
	> k: feedforward (0 to 1)
	> k: feedback (0 to 1)
	< a: out
	*/
	var sig = LADSPA.ar(1, 1767,
		in,
		\t.kr(30),
		\cwidth.kr(1.5),
		\crate.kr(2.5),
		1,
		\fwd.kr(0.8),
		\fb.kr(0.2)
	);

	LeakDC.ar(sig);
}))


(
~p2[\snd].filter(8, {arg in;

	var sig = in;

	3.do({
		//sig = XFade2.ar(sig, PitchShift.ar(sig, pitchRatio:2, pitchDispersion:0.1, timeDispersion:0.1), 0);
		sig = JPverb.ar(HPF.ar(sig, 420), t60:rrand(1,2), damp:0, size:rrand(1,5))
	});

	sig;

}).set(\wet8, 0.5)
)

(~p2[\snd].filter(10, {arg in;
	JPverb.ar(in);
}).set(\wet10, 0.0))


~p2[\snd].play(fadeTime:0);
~p2[\snd].stop(fadeTime:8)
~p2[\snd].vol = 1


App.recordWorkspace("ws5");
s.stopRecording


IEnvGen