/////////////////////////////////
// synth
(
SynthDef(\sinoscfb, {

	var freq = Vibrato.kr(\freq.kr(432).lag(\lag.kr(0.0)),
		\vrate.kr(6),
		\vdepth.kr(0.0),
		\vdelay.kr(0),
		\vonset.kr(0),
		\vrateVar.kr(0.04),
		\vdepthVar.kr(0.1)
	);

	var sig = Mix.fill(4,{
		//between 1 +- 0.01
		var freqmult = 1 + SinOsc.ar(LFNoise1.kr(rrand(0.25,0.5),4,5), pi.rand,0.01);
		SinOscFB.ar(freq * (freqmult), 0.5.rand);
	});

	var atk = \atk.kr(2);
	var sus = \atk.kr(2);
	var rel = \rel.kr(1);
	var curve = \curve.kr(4);
	var env = Env.linen(atk,sus,rel, curve:curve).kr(doneAction:2, gate:1, timeScale:1);

	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(0.1);

	sig = Pan2.ar(sig, \pan.kr(0));

	Out.ar(\out.kr(0), sig);

}).add;
)

(
~p[\sinoscfb][0] = Pbind(
	\instrument, \sinoscfb,

	\curve, [-4, 4],
	\sus, [2,1],
	\atk, [2,1],
	\pan, [-0.5, 0.5],
	\amp, 0.08,

	\delta, 16,
	\degree, Pbrown(0, 4, 1, inf),

	\vrate, [4,5],
	\vrateVar, [0.5, 0.1],
	\vdepthVar, [0.5, 0.3],

	\mtranspose, 0,
	\gtranspose, 0,
	\ctranspose, 0,
	\root, 0,
	\scale, Scale.kumoi,
	\stepsPerOctave, 12,

	\octave2, Prand([5, 6], inf),
	\degree2, Pkey(\degree) + (Prand([2, 5], inf) * Prand([-1,1], inf)),

	\f1, Pfunc({arg evt;
		var note = (evt[\degree] + evt[\mtranspose]).degreeToKey(evt[\scale], evt[\stepsPerOctave]);
		var midinote = ((note + evt[\gtranspose] + evt[\root])/ evt[\stepsPerOctave] + evt[\octave]) * 12.0;
		var freq = (midinote + evt[\ctranspose]).midicps;
		freq;
	}),
	\f2, Pfunc({arg evt;
		var note = (evt[\degree2] + evt[\mtranspose]).degreeToKey(evt[\scale], evt[\stepsPerOctave]);
		var midinote = ((note + evt[\gtranspose] + evt[\root])/ evt[\stepsPerOctave] + evt[\octave2]) * 12.0;
		var freq = (midinote + evt[\ctranspose]).midicps;
		freq;
	}),
	\freq, Ptuple([ Pkey(\f1), Pkey(\f2)], inf)
)
)

/////////////////////////////////
// fx

(~p[\sinoscfb][4] = \filter -> {arg in;
	JPverb.ar(in, t60:10, size:SinOsc.kr(1/32).range(1,2))
});

(~p[\sinoscfb][6] = \filter -> {arg in;
	Greyhole.ar(in, feedback:0.5, modDepth: 0.5, modFreq: LFTri.kr(1/64).range(2, 4));
})


/////////////////////////////////
// play
~p[\sinoscfb].play(fadeTime:8, vol:0.5);
~p[\sinoscfb].stop(fadeTime:8);
~p[\sinoscfb].vol = 0.5;

TempoClock.default.tempo_(45/60)





