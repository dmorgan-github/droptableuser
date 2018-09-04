

~syn2 = ProxySpace.new(s);
~syn2.quant = 4.0;
~syn2.clock = TempoClock.default;

(~syn2[\snd][0] = {

	var trig = \trig.tr;

	var freq = Vibrato.ar(K2A.ar(\freq.kr(432).lag(\lag.kr(0.0))),
		\vrate.kr(6),
		\vdepth.kr(0.0),
		\vdelay.kr(0),
		\vonset.kr(0),
		\vrateVar.kr(0.04),
		\vdepthVar.kr(0.1)
	);

	var sig1 = {

		//var sig = PMOsc.ar(freq, freq * 2.5, Env([13, 13, 0], [0,0.5], -4).kr(gate:trig), mul:0.2);
		//var env = Env([5,5,20],[0,1],1).kr(gate:trig);
		var env = Env.perc(attackTime:1, releaseTime:1).kr(gate:trig);
		var sig = RunningSum.rms(VarSaw.ar(freq, width: SinOsc.kr(1/4).range(0.3,0.7), mul:1), 75).tanh;
		LeakDC.ar(sig * env);
	};

	var sig2 = {

		var sig = Pluck.ar(WhiteNoise.ar,
			Impulse.kr( min(SinOsc.kr(0.2), LFNoise2.kr(0.5)).range(0.01,15)),
			(freq.lag(0.1)).reciprocal,
			(freq.lag(0.1)).reciprocal, 0.8, mul:0.1);

		var env = Env.linen(attackTime:2, releaseTime:2).kr(gate:trig);

		//sig = AllpassC.ar(sig, 0.1, 0.1, 5, mul:2, add:sig);

		//sig = sig + PitchShift.ar(sig, pitchRatio:2);

		//sig = FbC({arg fb; fb * 0.6 + sig}, 0.1);

		sig = sig * env;

		sig = GVerb.ar(sig, roomsize:50, revtime:30, taillevel:0.9);

		//sig = SVF.ar(sig, 3200, 0.1);

		sig * 0.6;// * env;
	};

	var env = Env.linen(releaseTime:2).kr(gate:trig);

	var sig = sig1.() + sig2.();

	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(0.1);

	sig = Pan2.ar(sig, \pan.kr(0));

	sig;
})

(~syn2[\snd][4] = \set -> Pbind(

	\trig, 1,
	\octave, 5,
	\scale, Scale.kumoi,
	[\degree, \delta], Pdefn(\mel) * [1,4],

	\vdepth, Pseg(Pseq([0.001, 0.01], inf), Pseq([0.3, 0.5]), -2, inf),
	\amp, 0.8
))

(
~syn2[\snd].filter(8, {arg in;
	Greyhole.ar(in, feedback:0.6)
}).set(\wet8, 0.3)
)

~syn2[\snd].gui
~syn2[\snd].play(fadeTime:0);
~syn2[\snd].play(fadeTime:4);
~syn2[\snd].stop(fadeTime:8);
~syn2[\snd].vol = 0.5


(
"----------".postln;
Pdefn(\mel, Ptuple([Pxrand([-2,0,1,2,3,4], inf), Prand([0.25,0.5,1,2], inf)], inf).trace )
)

#1
Pdefn(\mel, Ptuple([ Pseq([-2,2,1,3,2,1,0], inf), Pseq([0.5,1,2,0.5,0.5,1,2.5], inf)], inf))

[ -2, 0.5 ]
[ 2, 1 ]
[ 1, 2 ]
[ 3, 0.5 ]
[ 0, 0.5 ]
[ -2, 1 ]
[ 1, 1 ]

(
var matrix = [

	[ [0, 0.5],    [3 -> 0.5]],
	[ [2, 1],      [2 -> 0.3, 3 -> 0.7]],
	[ [-2, 0.25],  [1 -> 0.5, 0 -> 0.4]],
	[ [1,1],       [2 -> 0.1, 0 -> 0.9]],
	[ [-3, 0.5],   [0 -> 0.3, 1 -> 0.7]],

];

var matrix2 = [

	[ [0, 0.25],   [1 -> 0.7, 3 -> 0.3]],
	[ [2, 0.25],     [0 -> 0.3, 2 -> 0.7]],
	[ [-2, 0.5], [3 -> 0.8, 4 -> 0.2]],
	[ [1, 0.3],      [2 -> 0.1, 2 -> 0.9]],
	[ [nil,0.25],   [2 -> 0.1, 4 -> 0.9]]

];


var matrix3 = [

	[ [0, 0.125],   [1 -> 0.7, 3 -> 0.3]],
	[ [2, 0.125],   [0 -> 0.3, 2 -> 0.7]],
	[ [-2, 0.15],   [1 -> 0.8, 4 -> 0.2]],
	[ [1, 0.13],    [2 -> 0.1, 1 -> 0.9]],
	[ [nil,0.125],   [2 -> 0.1, 4 -> 0.9]]

];


var degree1 = ~pmarkov.(matrix, 2);
var degree2 = ~pmarkov.(matrix2, 2);
var degree3 = ~pmarkov.(matrix3, 2);

~bobo = Prand([degree1, degree2, degree3], inf);

~degrees = ~pmarkov.(matrix, 2);

)

~bobo2 = ~bobo.asStream
~bobo2.next


(


)


var markov = MarkovSetN.fill(~notes.size, Pseq.new(~notes).asStream, 5),


p = Pbind([\degree, \dur], ~degrees * [1,2], \scale, Scale.kumoi).trace.play

~degrees.next();






(

m = MarkovSetN([

			[[100, 120], [120, 130]],

			[[120, 100], [100, 1900]]

		], 2);

)



8.do { m.next([100, 120]).postln };

8.do { m.next([120, 100]).postln };



// training by a stream



m = MarkovSetN.fill(100, Prand([1, 2, 3, 4, Prand([5, 55, 555])], inf).asStream, 2);

n = m.makeSeeds.asStream

n.next

m.next([55,1]).postln

8.do { m.next([1,2]).postln };

8.do { m.next([3,4]).postln };

8.do { m.next([4,5]).postln };





(

SynthDef("mark", { arg out, freq, sustain=1, amp=0.1, pan;

	var env, u=1;

	env = EnvGen.kr(Env.perc(0.03, sustain, 5), 1, doneAction:2);

	3.do { var d; d = exprand(0.01, 1); u = SinOsc.ar(d * 300, u, rrand(0.1, 0.4) * d, 1) };

	Out.ar(out, Pan2.ar(SinOsc.ar(u + 1 * freq, 0, amp * env), pan));



}).add;

)



MIDIFreqPlayer

(

a = Pbind(
	\freq, Pshuf([203, 490, 231, 764, 234], inf),
	\dur, Pshuf([0.5, 0.5, 1.0, 0.25, 0.125, 0.5], inf)
);

m = MarkovSet.fill(20, Pevent(a, Event.default).asStream);

)

m.dict.keysValuesDo { |key, val| postf("key: %\t\tvalue: %\n", key, val) }; ""



// compare:

b = Pchain(Pfsm2(m), (instrument: \mark));

c = Pchain(a, (instrument: \mark));



Ppar([b, c]).play;