// tiny drum set
// multi synth
// sine section
// noise section
// granular section



//////////////////////////////////////////////////////

(
~buf = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/loops/loop_amen_full.aiff");
)

(

SynthDef(\kit_m, {

	var osc1 = {

		var dur = \ts.kr(1);
		var trig = \trig1.tr;
		var buf = ~buf;
		var pos = \pos.kr(0);
		var loop = \loop.kr(1);
		var rate = \rate.kr(1);

		var sig = PlayBufCF.ar(numChannels: 1, bufnum: buf, rate: BufRateScale.ir(buf) * rate, trigger: trig, startPos: pos, loop: loop, lag: 0.01);
		sig * Env([0,1,1,0], [0.001, dur, 0.01], -4).ar(gate: trig);
	};

	var fx1 = {arg sig;

		var fx = Squiz.ar(sig);
		fx;// * Decay2.ar(T2A.ar(\trig2.tr) ) * \mix1.kr(0.5);
	};

	var fx2 = {arg sig;

		var fx = PitchShift.ar(sig, pitchRatio: 2);
		fx;// * Decay2.ar(T2A.ar(\trig2.tr) ) * \mix1.kr(0.5);
	};


	var fx3 = {arg sig;

		var fx = GVerb.ar(sig, 300);
		fx;// * Decay2.ar(T2A.ar(\trig2.tr) ) * \mix1.kr(0.5);
	};

	var sig = osc1.();

	sig = XFade2.ar(sig, fx1.(sig), \pan1.kr(0) );

	sig = XFade2.ar(sig, fx2.(sig), \pan2.kr(0) );

	sig = XFade2.ar(sig, fx3.(sig), \pan3.kr(0) );

	sig = Pan2.ar(sig, \pan.kr(0)) * \amp.kr(0.1);

	Out.ar(\out.kr(0), sig);

}).add;
)

TempoClock.default.tempo_(60/60);

(

var buf = ~buf;
var beats = 8;
var beatDiv = 4;

var numFrames = buf.numFrames;
var sampleRate = buf.sampleRate;
var len = numFrames/sampleRate;
var bps = beats/len;
var slices = beats * beatDiv;
var fps = numFrames/slices;
var pos = (0..slices-1).collect({arg i; i * fps});

p = PmonoPar([
	[
		\dur, 0.5,
		\trig1, 1,
		\pos, Pseq([ 0, 9450, 18900, 28350, 37800, 47250, 56700, 66150 ], inf),
		\ts, Pfunc({ thisThread.clock.beatDur }) * Pkey(\dur),
		\loop, 1,
		\amp, 1
	],
	[
		\dur, 0.25,
		\pan1, Pseq([-1, 1], inf),
	],
	[
		\dur, 0.5,
		\pan2, Pseq([-1, 1], inf)
	],
	[
		\dur, 1,
		\pan3, Pseq([-1, 1], inf)
	]

], \kit_m).play;
)

p.stop

App.recordVersion
s.stopRecording
