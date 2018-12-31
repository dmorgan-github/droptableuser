MIDIClient.init;
m = MIDIOut(0);

(
SynthDef(\osc, {

	var freq = Vibrato.kr(\freq.kr(432), 6, 0.01);

	var sig = [
		SinOsc.ar(freq),
		LFTri.ar(freq * 1.01, 0.5)
	] * [0.4,1].normalizeSum;

	var env = Env.adsr(attackTime:0, decayTime:0.3, sustainLevel:0.02, releaseTime:0.3).kr(gate:\gate.kr(1), doneAction:Done.freeSelf);
	sig = sig.sum ring2: (SinOsc.ar(freq/2) * 0.3);

	sig = Pan2.ar(sig, \pan.kr(0)) * env * AmpCompA.kr(freq) * \amp.kr(-6.dbamp);
	Out.ar(\out.kr(0), sig);

}).add;

SynthDef(\osc2, {

	var freq = Vibrato.kr(\freq.kr(432), 6, 0.01);

	var sig = [
		SinOsc.ar(freq * SinOsc.kr(25).range(1.5, 2)).tanh,
	];//* [0.4,1].normalizeSum;

	var env = Env.adsr(attackTime:0, decayTime:0.3, sustainLevel:0.02, releaseTime:0.3).kr(gate:\gate.kr(1), doneAction:Done.freeSelf);
	sig = sig.sum;// ring2: (SinOsc.ar(freq/2) * 0.3);

	sig = Pan2.ar(sig, \pan.kr(0)) * env * AmpCompA.kr(freq) * \amp.kr(-6.dbamp);
	Out.ar(\out.kr(0), sig);

}).add;
)

6/16

Pdef(\p1).clear;

(
Pdef(\p1, {arg seq, offset;
	"init".debug(\p1);
	Pbind(
		\type, \midi,
		\midicmd, \noteOn,
		\midiout, m,
		//\chan, 0,
		//\instrument, \osc,
		\degrees, Pseq([0,1,2,4].scramble.pyramid.postln, inf),
		\seq, seq,
		\offset, offset,
		\foo, Pif(Pfunc({arg evt; evt[\seq].coin}), 1, Rest()),
		\degree, Pkey(\degrees) + Pkey(\offset),
		\scale, Scale.dorian,//Scale.kumoi,
		\mtranspose, 0,
		\root, 0,
		\dur, 0.25
	)
});

Pdef(\main, {

	"init".debug(\main);

	Ppar([
		{
			Pdef(\p1)
			<> (seq: Pseq([0,1,0,0,1,0,0,0,0,0], inf), offset:Pseq([0], inf))
			<> Pbind(\legato, 0.3, \amp, 1, \chan, 0, \octave, 6)
		}.(),

		{
			var offset = Pseq([0], inf).asStream;
			Pdef(\p1)
			<> (seq: Pseq([1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0], inf), offset:Pif(Pfunc({arg evt; evt[\seq] > 0}), Pfunc({offset.next}), Pn(0,inf)))
			<> Pbind(\octave, 5, \legato, 2, \amp, 1, \chan, 1)
		}.(),

		{
			Pdef(\p1)
			<> (seq: Pseq([1,0,0,0,0,0,0,0,0,0,0,0], inf), offset:0)
			<> Pbind(\octave, 4, \legato, 5, \amp, 1, \chan, 2)
		}.(),

		{
			Pdef(\p1)
			<> (seq: Pseq([0,0,0,1,0,0,0,0,0,0,0,0,0], inf), offset:0)
			<> Pbind(\octave, 7, \legato, 1, \amp, 1, \chan, 3)
		}.(),

		{
			Pdef(\p1)
			<> (seq: Pseq([0,1,0,1,0,0,1,0,0,1,0,0,0], inf), offset:0)
			<> Pbind(\octave, 4, \legato, 0.5, \amp, 1, \chan, 4)
		}.()

	], inf)
});
)

(
Pdef(\main, {

	"init".debug(\main);

	Ppar([
		{
			Pdef(\p1)
			<> (seq: Pseq([0,1,0,0,1,0,0,0,0,0], inf), offset:Pseq([2], inf))
			<> Pbind(\legato, 0.3, \amp, 1, \chan, 0, \octave, 6)
		}.(),

		{
			var offset = Pseq([0,1,2,3], inf).asStream;
			Pdef(\p1)
			<> (seq: Pseq([1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0], inf), offset:Pif(Pfunc({arg evt; evt[\seq] > 0}), Pfunc({offset.next}), Pn(0,inf)))
			<> Pbind(\octave, 5, \legato, 2, \amp, 1, \chan, 1)
		}.(),

		{
			Pdef(\p1)
			<> (seq: Pseq([1,0,0,1,0,0,0,0,0,1,0,0], inf), offset:0)
			<> Pbind(\octave, 4, \legato, 5, \amp, 1, \chan, 2)
		}.(),

		{
			Pdef(\p1)
			<> (seq: Pseq([0,0,0,1,0,0,0,0,0,0,0,0,0], inf), offset:0)
			<> Pbind(\octave, 7, \legato, 1, \amp, 1, \chan, 3)
		}.(),

		{
			Pdef(\p1)
			<> (seq: Pseq([0,1,0,1,0,0,1,0,0,1,0,0,0], inf), offset:0)
			<> Pbind(\octave, 4, \legato, 0.5, \amp, 1, \chan, 4)
		}.()

	], inf)
});
)

~s1test.play(vol:0.6);
~s1_del.play(vol:0.3);
~s1_rev.play(vol:0.1);
Pdef(\main).play;


Pspawner({arg ps;

	inf.do({
		ps.seq(Pfindur(25, Pdef(\main)));
		ps.wait(8)
	});

}).play;

Pfindur(25, Pdef(\main)).play;



Pdef(\main).stop;
~s1test.stop;
~s1_del.stop;
~s1_rev.stop;

~s1test.play(vol:0.6);
~s1test.stop;
~s1test[0] = Pdef(\main);


(~s1_del = {
	var in = \in.ar([0,0]);
	var fx = FbC({arg fb;
		//PitchShift.ar(fb * 0.6 + in, 0.5, [2, 1.5], 0.01, 0.01);
		fb * 0.4 + in
	}, [3/8, 5/8]);
	fx;//LPF.ar(fx, 7000);
})

(
~s1_rev = {
	var in = \in.ar([0,0]);
	var fx = JPverb.ar(HPF.ar(in, 110), 10, 0, SinOsc.kr(1/32).range(1, 1.2));
	fx;
};
)

~s1_del.play(vol:0.4);
~s1_del <<> ~s1test;

~s1_mix[0] = \mix -> {~s1test.ar;}
~s1_mix[1] = \mix -> {~s1_del.ar;}

~s1_rev.play(vol:0.1);
~s1_rev <<> ~s1_mix;


s.record;
s.stopRecording

TempoClock.default.tempo_(60/60)


(
var a = 1;
Pbind(
	\bar, #[1],
	\foo, #[a] ++ Pkey(\bar)).trace.play
)
