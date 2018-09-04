
/////////////////////////////////////////
// proxy space
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(60/60);


/////////////////////////////////////////
// s1
~p[\s1].clear;
~p[\s1].mold;
(~p[\s1][0] = {

    var trig = \trig.tr;
	var freq = Vibrato.kr(\freq.kr(432).lag(\lag.kr(0)), \vrate.kr(6), \vdepth.kr(0.0));

	var osc1 = {
		var sig = VarSaw.ar(freq, \width.kr(0.5));
		sig = RLPF.ar(sig, SinOsc.kr(1).range(220, 1200), 0.8);
		sig;
	};

	var env = Env(
		[0,\peakLevel.kr(1),\susLevel.kr(0.5),0],
		[\atk.kr(0.01), \decay.kr(0.3), \sus.kr(1), \rel.kr(1)],
		curve:\curve.kr(-4)
	).kr(gate:trig);

	var sig = [
		osc1.()
	].sum;

	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(-12.dbamp);
	sig = Pan2.ar(sig, \pan.kr(0));
	//sig = sig + JPverb.ar(sig, 5, 0, 5);
	sig;
});
~p[\s1].play(vol:1);
~p[\s1].stop;
~p[\s1].gui;

/////////////////////////////////////////
// s2
~p[\s2].clear;
~p[\s2].mold;
(~p[\s2][0] = {
    var trig = \trig.tr;
	var freq = Vibrato.kr(\freq.kr(432).lag(\lag.kr(0)), \vrate.kr(6), \vdepth.kr(0.0));

	var osc1 = {
		var sig = SinOscFB.ar(freq, 0, \fb.kr(0.7));
		sig;
	};

	var env = Env(
		[0,\peakLevel.kr(1),\susLevel.kr(0.5),0],
		[\atk.kr(0.01), \decay.kr(0.3), \sus.kr(1), \rel.kr(1)],
		curve:\curve.kr(-4)
	).kr(gate:trig);

	var sig = [
		osc1.()
	].sum;

	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(-12.dbamp);
	sig = Pan2.ar(sig, \pan.kr(0));
	//sig = sig + JPverb.ar(sig, 5, 0, 5);
	sig;
});
~p[\s2].play;
~p[\s2].stop;
~p[\s2].gui;

/////////////////////////////////////////
// s3
~p[\s3].clear;
~p[\s3].mold;
(~p[\s3][0] = {

    var trig = \trig.tr;
	var freq = Vibrato.kr(\freq.kr(432).varlag(\lag.kr(0.01)), \vrate.kr(6), \vdepth.kr(0.0));

	var osc1 = {
		var sig = SinOsc.ar(freq);
		sig;
	};

	var env = Env(
		[0,\peakLevel.kr(1),\susLevel.kr(0.5),0],
		[\atk.kr(0.01), \decay.kr(0.3), \sus.kr(1), \rel.kr(1)],
		curve:\curve.kr(-4)
	).kr(gate:trig);

	var sig = [
		osc1.()
	].sum;

	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(-12.dbamp);
	sig = Pan2.ar(sig, \pan.kr(0));

	//sig = sig + JPverb.ar(sig, 5, 0, 5);
	sig;
});
~p[\s3].play;
~p[\s3].stop;
~p[\s3].gui;

/////////////////////////////////////////
// send1
~p[\send1].clear;
(~p[\send1][0] = {
	var in = \in.ar([0,0]);
	var fx = FbC({arg fb; fb * 0.3 + in}, [3/8, 5/8]);
	fx
});
~p[\send1].play;
~p[\send1].stop;
~p[\send1].gui;
~p[\send1] <<> ~p[\s2];

/////////////////////////////////////////
// send2
~p[\send2].clear;
(~p[\send2][0] = {
	var in = \in.ar([0,0]);
	var fx = DelayC.ar(in, 0.5, SinOsc.kr(1/32).range(0.2, 0.5));
	fx = FreqShift.ar(fx, [400,-100], 0);
	fx = PitchShift.ar(in, 0.5, 2);
	fx;
});
~p[\send2].play(vol:0.7);
~p[\send2].stop;
~p[\send2].gui;

~p[\send2] <<> ~p[\send1];


/////////////////////////////////////////
// mix1
~p[\mix1].clear;
~p[\mix1][0] = \mix -> {~p[\s1]};
~p[\mix1][1] = \mix -> {~p[\s2]};
~p[\mix1][2] = \mix -> {~p[\s3]};
~p[\mix1][3] = \mix -> {~p[\send1]};
~p[\mix1][4] = \mix -> {~p[\send2]};
~p[\mix1].play;
~p[\mix1].stop;
~p[\mix1].gui;
~p[\mix1].set(\mix0, 1, \mix3, 1, \mix4, 0.5);


/////////////////////////////////////////
// send3
~p[\send3].clear;
(~p[\send3][0] = {
	var in = \in.ar([0,0]);
	var fx = RLPF.ar(in, SinOsc.kr(5).range(440, 2200), \rq.kr(0.8));
	fx = LPF.ar(fx, 880);
	fx;
});
~p[\send3].play(vol:1);
~p[\send3].stop;
~p[\send3].gui;
~p[\send3] <<> ~p[\mix1];


/////////////////////////////////////////
// patterns

Pdef(\p1).clear;
Pdef(\p2).clear;
Pdef(\p3).clear;

(
Pdef(\base, Pbind(
	\degree, Pseq([0,1,3,5], inf),
	\scale, Scale.locrian,
	\dur, Pseq([0.5, 0.25, 1, 2.25], inf)
));

Pdef(\p1, Pproto({
	var node = topEnvironment[\p][\s1];
	node.play;
	~id = node.nodeID;
	~type = \set
}, Pbind(
	\args, #[\trig, \freq, \sus, \decay, \rel, \amp],
	\trig, 1,
	\sus, 2,
	\decay, 0.1,
	\rel, 2
)));

Pdef(\p2, Pproto({
	var node = topEnvironment[\p][\s2];
	node.play;
	~id = node.nodeID;
	~type = \set
}, Pbind(
	\args, #[\trig, \freq, \sus, \decay, \rel, \amp],
	\trig, 1,
	\sus, 2,
	\decay, 0.1,
	\rel, 2
)));

Pdef(\p3, Pproto({
	var node = topEnvironment[\p][\s3];
	node.play;
	~id = node.nodeID;
	~type = \set
}, Pbind(
	\args, #[\trig, \freq, \sus, \decay, \rel, \amp],
	\trig, 1,
	\sus, 2,
	\decay, 0.1,
	\rel, 2
)));
)

App.recordWorkspace("ws10");
s.stopRecording;

/////////////////////////////////////////
// scenes
(
Pdef(\main, Ppar([
	Pdef(\p1) <> Pdef(\base) <> Pbind(\octave, 5, \timingOffset, 0, \mtranspose, 0),
	Pdef(\p2) <> Pdef(\base) <> Pbind(\octave, 6, \timingOffset, 3, \mtranspose, 0),
	Pdef(\p3) <> Pdef(\base) <> Pbind(\octave, 7, \timingOffset, 5, \mtranspose, 0)
], inf))
)

(
Pdef(\main, Ppar([
	Pdef(\p1) <> Pdef(\base) <> Pbind(\octave, 5, \timingOffset, 0, \mtranspose, 0),
	Pdef(\p2) <> Pdef(\base) <> Pbind(\octave, 6, \timingOffset, 3, \mtranspose, 1),
	Pdef(\p3) <> Pdef(\base) <> Pbind(\octave, 7, \timingOffset, 5, \mtranspose, -2)
], inf))
)

(
Pdef(\main, Ppar([
	Pdef(\p1) <> Pdef(\base) <> Pbind(\octave, 5, \timingOffset, 0, \mtranspose, 0),
	Pdef(\p2) <> Pdef(\base) <> Pbind(\octave, 6, \timingOffset, 3, \mtranspose, 2),
	Pdef(\p3) <> Pdef(\base) <> Pbind(\octave, 7, \timingOffset, 5, \mtranspose, -2)
], inf))
)

(
Pdef(\main, Ppar([
	Pdef(\p1) <> Pdef(\base) <> Pbind(\octave, 5, \timingOffset, 0, \mtranspose, 0),
	Pdef(\p2) <> Pdef(\base) <> Pbind(\octave, 6, \timingOffset, 3, \mtranspose, 0),
	Pdef(\p3) <> Pdef(\base) <> Pbind(\octave, 7, \timingOffset, 5, \mtranspose, 5)
], inf))
)

(
Pdef(\main, Ppar([
	Pdef(\p1) <> Pdef(\base) <> Pbind(\octave, 5, \timingOffset, 0, \mtranspose, 0),
	Pdef(\p2) <> Pdef(\base) <> Pbind(\octave, 6, \timingOffset, 3, \mtranspose, 0),
	Pdef(\p3) <> Pdef(\base) <> Pbind(\octave, 7, \timingOffset, 5, \mtranspose, -2)
], inf))
)

Pdef(\main).play;
Pdef(\main).stop

App.recordWorkspace("ws10");
s.stopRecording

Onsets


(
var pbind = Pbind(\degree, Pseq([0,1,3,5], inf), \scale, Scale.locrian, \dur, Pseq([0.5, 0.25, 1, 2.25], inf));

var p1 = pbind <> Pdef(\p1, Pbind(\octave, 5, \timingOffset, 0));

var p2 = pbind <> Pdef(\p2, Pbind(\octave, 6, \timingOffset, 3));

var p3 = pbind <> Pdef(\p3, Pbind(\octave, 7, \timingOffset, 5));

Ppar([
	p1, p2, p3
], inf).play;

)

App.recordWorkspace("ws10");
s.stopRecording;