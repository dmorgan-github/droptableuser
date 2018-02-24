~res = ProxySpace.new(s);
~res.defaultReshaping = \elastic;
~res.quant = 1.0;

/////////////////////////////////
// main sequencer
(~res[\seq1] = {
	var freq = \freq.kr;
	var trig = \trig.tr;
	[trig, freq];
});
(~res[\seq1][4] = \set -> Pbind(
	\trig, 1,
	\scale, Scale.kumoi,
	\degree, Ppatlace([Pseq([0,6], inf), Pseq([2,3,5,4], inf)], inf),
	\ctranspose, Pstep(Pseq([0, -5, 2, -7], inf), Pseq([4,4,4,4] * 4, inf), inf),
	\octave, 4,
	\delta, Pseq([ 8, [1,1,1,1,1,1,[1, [1,1,1]],1] ].convertRhythm, inf) * 0.25,
	//Pseq([0.25, 0.25, 0.25, 0.25, 0.25, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125], inf), //0.25,
	\isRest, false, //Pwrand([true, false], [0.1,0.9], inf)
));


/////////////////////////////////
// trig
~res[\trig1] = {~res[\seq1].kr[0]}

/////////////////////////////////
// freq
~res[\freq] = {~res[\seq1].kr[1]};

/////////////////////////////////
// exciter
(~res[\ex] = {

	var trig = ~res[\trig1];
	var start = 1;
	var end = 0;
	var dur = [0.01, 0.01];
	var curve = -4;
	var env = Env([start,start,end],[0,dur],curve).kr(gate:trig);

	PinkNoise.ar/* Blip.ar(200, 30)*/ * env;
});

/////////////////////////////////////////////////////////
// resonator
(~res[\snd] = {

	var numFreqs = 6;

	var freq_in = Vibrato.ar(K2A.ar(\freq.kr(432).lag(\lag.kr(0.0))),
		\vrate.kr(6),
		\vdepth.kr(0.0),
		\vdelay.kr(0),
		\vonset.kr(0),
		\vrateVar.kr(0.04),
		\vdepthVar.kr(0.1)
	);

	var in = \in.ar([0]);

	var detune = \detune.kr(0);

	var ffreqs = (0..numFreqs-1).collect({arg i;
		(\f ++ i).asSymbol.kr(1);
	}) + detune;

	var amps = (0..numFreqs-1).collect({arg i;
		(\a ++ i).asSymbol.kr(1/numFreqs);
	});

	var rings = (0..numFreqs-1).collect({arg i;
		(\r ++ i).asSymbol.kr(1);
	});

	var sig = DynKlank.ar(`[freq_in * ffreqs, amps, rings], in);

	sig = sig * AmpCompA.kr(freq_in) * \amp.kr(0);

	Splay.ar(sig);

});
~res[\snd] <<> ~res[\ex];

(~res[\fl1] = {

	var trig = ~res[\trig1];
	var start = 0.1;
	var end = 3.2;
	var dur = 0.01;
	var curve = -4;
	var env = Env([start,start,end],[0,dur],curve).kr(gate:trig);

});

(~res[\snd].set(\amp, 0.1,

	\freq, ~res[\freq],
	\vdepth, 0.001,
	\lag, 0.0012,

	\f0, 1.02340,
	\f1, ~res[\fl1],
	\f2, 5.234,
	\f3, 9.123,
	\f4, 11.23,
	\f5, 13.93930,

	\detune, 0.0,

	\r0, 1,
	\r1, 1/2,
	\r2, 1/3,
	\r3, 1/4,
	\r4, 1/5,
	\r5, 1/8

));
~res[\snd].gui
~res[\snd].vol = 1;
~res[\snd].play;
~res[\snd].stop

(~res[\snd][10] = \filter -> {arg in;
	JPverb.ar(in, t60:3, size:3);
});
~res[\snd].set(\wet10, 0.4);

/////////////////////////////////
// fork the sound
~res[\snd2][0] = {~res[\snd]};
// barry's
/*
# 1408 Barry's Satan Maximiser
> k: Decay time (samples) (2 to 30)
> k: Knee point (dB) (-90 to 0)
> a: Input
< a: Output
*/
(~res[\snd2][4] = \filter -> {arg in;
	LADSPA.ar(1, 1408,
		\decay.kr(25),
		\kneepoint.kr(-50),
		in
	);
});
(~res[\snd2][8] = \filter -> {arg in;
	JPverb.ar(in);
});
(~res[\snd2][10] = \filter -> {arg in;
	PitchShift.ar(in, 0.05, \pitchratio.kr(1), 0.01, 0.01);
})
~res[\snd2][20] = \set -> Pbind(\pitchratio, Prand([0.5, 0.75, 1, 2, 4], inf), \delta, 4);

~res[\snd2].gui
~res[\snd2].play
~res[\snd2].stop
~res[\snd2].vol = 0.1;
~res[\snd2].set(\wet8, 0.3)




