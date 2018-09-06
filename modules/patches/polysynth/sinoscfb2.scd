/////////////////////////////////
// synth
(
SynthDef(\sinoscfb, {

	var freq = Vibrato.ar(K2A.ar(\freq.kr(432).lag(\lag.kr(0.0))),
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
		SinOscFB.ar(freq * (freqmult), 0.7.rand);
	});

	var atk = \atk.kr(2);
	var sus = \atk.kr(2);
	var rel = \rel.kr(1);
	var curve = \curve.kr(4);
	var env = Env.linen(atk,sus,rel, curve:curve).kr(doneAction:2, gate:1, timeScale:1, mul:1);

	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(0.1);

	sig = Pan2.ar(sig, \pan.kr(0));

	Out.ar(\out.kr(0), sig);

}).add;
)

/////////////////////////////////
// patch
~sinoscfb2 = ProxySpace.new(s);
~sinoscfb2.quant = 4.0;
~sinoscfb2.clock = TempoClock.default;


(
~sinoscfb2[\snd][0] = Pbind(
	\instrument, \sinoscfb,

	\delta, 4,

	\curve, [-4, 4],
	\sus, [0,0],
	\atk, [0.01,0.01],
	\pan, [-0.5, 0.5],
	\amp, 0.08,

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

	\octave2, Prand([4, 5], inf),
	\degree2, Pkey(\degree) + (Prand([2, 3], inf) * Prand([-1,1], inf)),

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
(~sinoscfb2[2] = \filter -> {arg in; { in = BHiPass.ar(in, 100) }.dup(4) })


(~sinoscfb2[\snd][4] = \filter -> {arg in;
	JPverb.ar(in, t60:10, size:5)
});

(~sinoscfb2[\snd][6] = \filter -> {arg in;

	var delay1, delay2;

	var t = 30, width = 1.5, rate = 2.5, blend = 1, feedforward = 0.8, feedback = 0.2;

	var sig = LADSPA.ar(1, 1767,
		in,
		t,
		width,
		rate,
		blend,
		feedforward,
		feedback
	);

	delay2 = FbC({arg fb; fb * 0.6 + sig + PitchShift.ar(sig, windowSize:0.5, pitchRatio:2, pitchDispersion:0.02, timeDispersion:0.5)}, 0.05);

	delay1 = FbC({arg fb; fb * 0.3 + sig + delay2}, 0.5);

	sig = sig + delay1;

	//sig = RunningSum.rms(sig, 30);

	sig = SVF.ar(sig, SinOsc.kr(1/32).range(1200, 4000), 0.2);

})

(~sinoscfb2[\snd][8] = \filter -> {arg in;
	WaveLoss.ar(in, LFTri.kr(1/16).range(1, 20));
})

~sinoscfb2[\snd].set(\wet4, 0.5, \wet6, 0.7, \wet8, 0.0)

/////////////////////////////////
// play
~sinoscfb2[\snd].play(fadeTime:8);
~sinoscfb2[\snd].stop(fadeTime:4);
~sinoscfb2[\snd].vol = 0.5;

TempoClock.default.tempo_(120/60);
~sinoscfb2[\snd].gui

App.recordWorkspace("ws3");
~sinoscfb2[\snd].play(fadeTime:8);
s.stopRecording






