(
SynthDef(\pad, {

	var freq = \freq.kr(432);

	var osc1 = {arg i = 0;
		var myfreq = Vibrato.kr(freq, 6, 0.001) * LFNoise2.kr(0.1).range(-0.05, 0.05).midiratio;
		var sig = [
			SinOscFB.ar(myfreq, 0.7),
			SinOsc.ar(myfreq) * 0.5 * (i + 1).reciprocal
		].sum;
		sig * AmpCompA.kr(myfreq);
	};

	var sig = osc1.dup(4);
	var env = Env.adsr(
		\atk.kr(0.01),
		\decay.kr(0.3),
		\susLevel.kr(0.5),
		\rel.kr(1),
		curve:\curve.kr(-4)
	).kr(gate:\gate.kr(1), doneAction:Done.freeSelf);
	sig = Splay.ar(sig) * env * \amp.kr(-12.dbamp);
	Out.ar(\out.kr(0), sig);

}).add;
)

/////////////////////////////////////////
// proxy space
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(35/60);

/////////////////////////////////////////
// pad
~p[\pad].clear;
~p[\pad].mold;
(~p[\pad][0] = Pbindef(\bobo,
	\instrument, \pad,
	\scale, Scale.locrian,
	// nice chord progression modified from http://sccode.org/1-597
	\degree, Pseq([
        [2, 4, 6, 10],
        [1, 4, 6, 9],
		[0, 2, 4, 6, 8],
        [0, 3, 5, 8]
    ], inf),
	\octave, 4,
	\dur, 4,
	\atk, 2,
	\sustain, 4,
	\susLevel, 0.7,
	\rel, 1.5,
	\foo, Pfunc({arg evt;

		var freq, note, midinote;
		var scale = evt[\scale] ? Scale.major;
		var stepsPerOctave = evt[\stepsPerOctave] ? 12.0;
		var degree = evt[\degree] ? 0.0;
		var mtranspose = evt[\mtranspose] ? 0.0;
		var gtranspose = evt[\gtranspose] ? 0.0;
		var root = evt[\root] ? 0.0;
		var ctranspose = evt[\ctranspose] ? 0.0;
		var harmonic = evt[\harmonic] ? 1.0;
		var octave = evt[\octave] ? 5.0;

		note = (degree + mtranspose).degreeToKey(scale, stepsPerOctave);
		midinote = ((note + gtranspose + root) / stepsPerOctave + octave) * 12.0;
		freq =  (midinote + ctranspose).midicps * harmonic;
		freq.cpsname.postln;
	})

));
~p[\pad].play(out:0);
~p[\pad].stop;
~p[\pad].gui;

/*
[ Eb2, F#2, Bb2, F3 ]
[ C#2, F#2, Bb2, Eb3 ]
[ C2, Eb2, F#2, Bb2, C#3 ]
[ C2, F2, F#2, G#2, C#3 ]
*/

/////////////////////////////////////////
// fx1
~p[\fx1].clear;
(~p[\fx1][0] = {
	var in = ~p[\pad].ar;
	var fx = (WaveLoss.ar(in) * 4).tanh;
	fx * 0.4
});
~p[\fx1].play(out:0, vol:0.6);
~p[\fx1].stop;
~p[\fx1].gui;

/////////////////////////////////////////
// fx2
~p[\fx2].clear;
(~p[\fx2][0] = {
	var in = ~p[\pad].ar;
	var fbNode = FbNode(2, 5, 4);
	var fb = fbNode.delay(2);
	var sig = fb * 0.4 + in;
	sig = PitchShift.ar(sig, 0.5, 2);
	sig = SoftClipAmp8.ar(sig, 2.1);
	sig = RLPF.ar(sig, SinOsc.kr(0.1).range(330, 2880), SinOsc.kr(1/8).range(0.3,0.8));
	fbNode.write(sig.tanh);
	JPverb.ar(sig, 5, 0, SinOsc.kr(1/64).range(1.0,2.0)) * 0.2
});
~p[\fx2].play(out:0);
~p[\fx2].stop;
~p[\fx2].gui;

App.recordWorkspace("ws10");
s.stopRecording



App.recordWorkspace("ws10");
~p[\pad][0].reset;
~p[\pad].play(fadeTime:3);
~p[\fx1].play(fadeTime:30, vol:0.6);
~p[\fx2].play(fadeTime:10);

~p[\pad].stop(fadeTime:10);
~p[\fx1].stop(fadeTime:10);
~p[\fx2].stop(fadeTime:10);





/////////////////////////////////////////
// s1
~p[\s11].clear;
~p[\s11].mold;
(~p[\s11][0] = {

	var trig = \trig.tr;
	var freq = \freq.kr(432);
	var sig = SinOsc.ar(freq);
	var env = Env.perc.kr(gate:trig);
	sig = Pan2.ar(sig, \pan.kr(0)) * env * AmpCompA.kr(freq) * \amp.kr(-12.dbamp);
	sig;
});
~p[\s11].play(out:0);
~p[\s11].stop;
~p[\s11].gui;

(~p[\s11][2] = \set -> Pbind(
    \trig, 1,
	\scale, Scale.locrian,
	\degree, Ppatlace([Pseq([0,6], inf), Pshuf([1,2,3,4,5].scramble[0..3], inf)], inf),
	\octave, Pbjorklund(7, 11).collect({arg val; if (val == 0) {6}{7}}),
	\dur, 0.25,
	\amp, -15.dbamp
));

/////////////////////////////////////////
// f3
(~p[\f3][0] = {
	var in = ~p[\s11].ar;
	var fx = FbC({arg fb; fb * 0.5 + in}, [3/8, 5/8]);
	fx
});
~p[\f3].play(out:0);
~p[\f3].stop;
~p[\f3].gui;

