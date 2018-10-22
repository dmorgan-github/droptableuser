/////////////////////////////////////////
// kik
~p[\kik].clear;
~p[\kik].mold;
(~p[\kik][0] = {

	// 80560
	// 53270
	// 8304
	// 16580
	// 12778
	var foo = { thisThread.randSeed_(100000.rand.postln) }.();

	var trig = \trig.tr;

	var freq = {
		var start = rrand(300.0, 500.0);
		var end = start/10;
		var curve = -14.rand;
		var dur = 0.1.rand;
		Env([start,start,end],[0,dur],curve).kr(gate:trig);
	}.dup(6);

	var sig = SinOsc.ar(freq) + SinOsc.ar(61);
	var env = Env.perc(releaseTime:1).kr(gate:trig, doneAction:Done.none);

	sig = sig + {
		sig ring1: (SinOsc.ar(220) * LFPulse.kr(SinOsc.kr(2).range(4, 14)) * -10.dbamp);
	}.();

	sig = BLowShelf.ar(sig, 60, 1, 2);
	sig = BPeakEQ.ar(sig, 100, 1, 2);
	sig = Pan2.ar(sig.sum, \pan.kr(0)) * env * \amp.kr(-10.dbamp);
    sig;
});
~p[\kik].play(vol:1)
~p[\kik].stop;
~p[\kik].gui;



(
Pdef(\kik, Pproto({
	var node = topEnvironment[\p][\kik];
	node.play;
	~id = node.nodeID;
	~type = \set
}, Pbind(
	\trig, 1,
	\dur, Pseq([3,5], inf) * 0.25,
	\amp, -15.dbamp
))).quant_(4.0)
)

Pdef(\kik).play

/////////////////////////////////////////
// res
~p[\res].clear;
~p[\res].mold;
(~p[\res][0] = {

	var in = {
		var trig = \trig.tr;
		var env = Env([1,1,0],[0,0.05],-4).kr(gate:trig);
		PinkNoise.ar * env;
	}.();

	var numFreqs = 6;

	var freq_in = Vibrato.ar(K2A.ar(\freq.kr(432).varlag(\lag.kr(0.0))),
		\vrate.kr(6),
		\vdepth.kr(0.0),
		\vdelay.kr(0),
		\vonset.kr(0),
		\vrateVar.kr(0.04),
		\vdepthVar.kr(0.1)
	);

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

	sig = sig * AmpCompA.kr(freq_in) * \amp.kr(-10.dbamp);

	sig = Pan2.ar(Mix.ar(sig), \pan.kr(0));

});
~p[\res].play(vol:0.1)
~p[\res].stop;
~p[\res].gui;

(~p[\res].filter(2, {arg in;
	in + FbC({arg fb; fb * 0.1 + in}, [3/8, 5/8]);
}));


Pdef(\res).clear;
(
Pdef(\res, Pproto({
	var node = topEnvironment[\p][\res];
	node.play;
	~id = node.nodeID;
	~type = \set
}, Pbind(

	\args, #[\trig, \freq,
		\f0, \f1, \f2, \f3, \f4, \f5, \r0,
		\r1, \r2, \r3, \r4, \r5,
		\vdepth, \amp],

	\trig, 1,
	\scale, Scale.kumoi,
	\degree, 0,//Ppatlace([Pseq([0,6], inf), Pseq([2,1,3,4], inf)], inf),
	\ctranspose, Pstep(Pseq([0, -5, 2, -7], inf), Pseq([4,4,4,4] * 4, inf), inf),
	\octave, 3,
	\delta, Pseq([
		Pseq([Rest(1.5), 3.5], inf) * 0.5,
	], inf),
	\amp, -20.dbamp,

	\foo, Pseg([0, 50, 25, 0], [1, 2, 3], \lin, inf),

	\f0, 1.02340 * Pkey(\foo).lincurve(0, 50, 1, 2, 24),
	\f1, 3.2  * Pkey(\foo).lincurve(0, 50, 1, 2, -24),
	\f2, 5.234 * Pkey(\foo).lincurve(0, 50, 1, 2, 4),
	\f3, 9.123 * Pkey(\foo).lincurve(0, 50, 1, 2, -4),
	\f4, 11.23  * Pkey(\foo).lincurve(0, 50, 1, 2, 10),
	\f5, 13.93930 * Pkey(\foo).lincurve(0, 50, 1, 2, -10),

	\detune, 0.001,

	\r0, 1,
	\r1, 1/2,
	\r2, 1/4,
	\r3, 1/5,
	\r4, 1/6,
	\r5, 1/8,

	\vdepth, 0.001,
	\lag, 0,
))).quant_(4.0)
)

Pdef(\res).play;

/////////////////////////////////////////
// part1
(
Pdef(\part1, Ppar([
	Pdef(\res),
	Pdef(\kik)
], inf))
)

App.recordWorkspace("ws7");

(
Pdef(\res).reset;
Pdef(\kik).reset;
Pdef(\part1).play;
)

Pdef(\res).play;
Pdef(\kik).play
