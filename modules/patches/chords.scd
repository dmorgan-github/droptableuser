/////////////////////////////////////////
// proxy space
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(60/60);

(
SynthDef(\s1, {

	var freq = Vibrato.kr(\freq.kr(432), 6, 0.001);
	var sig = {
		var sig = SinOsc.ar(freq);
		sig;
	}.();
	var env = Env.adsr(attackTime:0.001, releaseTime:3).kr(gate:\gate.kr(1), doneAction:Done.freeSelf);
	sig = Pan2.ar(sig, \pan.kr(0)) * env * AmpCompA.kr(freq) * \amp.kr(-10.dbamp);
	Out.ar(\out.kr(0), sig);

}).add;
)

/////////////////////////////////////////
// chord
~p[\chord].clear;
~p[\chord].mold;


(
~p[\chord][0] = Pbind(
	\instrument, \s1,
	\scale, Scale.chromatic,
	\octave, 6,
	\pan, 0,
	\detune, Pwhite(-1.0, 1.0),
	\degree, Pseq([
		Pn([-5, -3, 2], 1),
		Pn([-3, -1, 6], 1),
		Pn([ 2,  4, 9], 1),
		Pn([ 0,  2, 7], 1),
	], inf),
	\dur, 8,
	\sustain, Pkey(\dur) * 0.7,
	\amp, -10.dbamp
);

App.recordWorkspace("ws9");
~p[\chord].play(vol:1, fadeTime:0);
~p[\rev].play(fadeTime:0);
~p[\dist].play(vol:0.04, fadeTime:45);

);

~p[\chord].play(vol:1);
~p[\chord].stop;
~p[\chord].gui;


~p[\bufplay].mold;
(~p[\bufplay][0] = {

	var in = \in.ar([0,0]);

	var buf = LocalBuf(s.sampleRate * 16, 1).clear;

	var foo = {

		var rec = \rec.kr(1);
		var renv = Env.asr.kr(gate:rec);
		var penv = Env.asr.kr(gate:rec) * \plevel.kr(0);

		RecordBuf.ar(Mix.ar(in),
			buf,
			recLevel:renv,
			preLevel:penv,
			run:rec,
			loop:\rec_loop.kr(0),
			trigger:\rec_trig.kr(1)
		);
	}.();

	var pos = \pos.kr(0) * BufFrames.kr(buf);
	var trig = \trig.tr;
	var loop = \loop.kr(1);
	var sig = PlayBufCF.ar(1, buf, rate:\rate.kr(1), trigger:trig, startPos:pos, loop:loop);
	Pan2.ar(sig, \pan.kr(0));
});

~p[\bufplay].set(\rec_loop, 1, \rec, 1, \plevel, 0, \rate, -1, \pos, 0, \trig, 0, \loop, 1)
~p[\bufplay] <<> ~p[\chord];
~p[\bufplay].play;
~p[\bufplay].stop;


/////////////////////////////////////////
// dist
(~p[\dist][0] = {

	var fx;
	var in = ~p[\bufplay];//~p[\chord].ar;
	fx = JPverb.ar(in, 10, 0, 5, modDepth:0.5);
	fx = LADSPA.ar(1, 1408,
		[\decayL.kr(10), \decayR.kr(10)],
		[\kneepointL.kr(-10), \kneepointR.kr(-10)],
		fx
	);
	//fx = CrossoverDistortion.ar(fx, 0.1, 0.3);
	//fx = SoftClipAmp8.ar(fx, 3);
	//fx = WaveLoss.ar(fx);
	//fx = HPF.ar(in, 220);
	fx = fx + PitchShift.ar(fx, 0.5, 2);
	fx = JPverb.ar(fx, 3, 0, 5, modDepth:0.8);
	fx;
});

ControlSpec.specs[\decayL] = [2, 30, \lin, 0, 10].asSpec;
ControlSpec.specs[\decayR] = [2, 30, \lin, 0, 10].asSpec;
ControlSpec.specs[\kneepointL] = [-90, 1, \lin, 0, -10].asSpec;
ControlSpec.specs[\kneepointR] = [-90, 1, \lin, 0, -10].asSpec;


~p[\dist].play(vol:0.04);
~p[\dist].stop;
~p[\dist].gui;

App.recordWorkspace("ws9");
s.stopRecording


/////////////////////////////////////////
// rev
~p[\rev].clear;
(~p[\rev][0] = {
	var in = ~p[\chord].ar;
	var fx = JPverb.ar(in, 5, 0, 5, modDepth:0.6);
	fx;
});
~p[\rev].play;
~p[\rev].stop;
~p[\rev].gui;


# 1209 Valve saturation
> k: Distortion level (0 to 1)
> k: Distortion character (0 to 1)
> a: Input
< a: Output


~p[\chord].stop(fadeTime:30);
~p[\rev].stop(fadeTime:30);
~p[\dist].stop(fadeTime:30);
s.stopRecording


App.recordWorkspace("ws9");
~p[\chord].play(vol:1, fadeTime:0);
~p[\rev].play(fadeTime:0);
~p[\dist].play(vol:0.04, fadeTime:30);


/////////////////////////////////////////
// fx1
(~p[\fx1][0] = {
	var fx;
	var in = ~p[\chord].ar;
	var lfo = SinOsc.kr(0.5).range(0.5,1);
	in = PitchShift.ar(in.tanh, 0.5, pitchRatio:2, pitchDispersion:0.001, timeDispersion:lfo);
	//in = LPF.ar(in, 880);
	fx = Fb({arg fb; fb * 0.3 + in}, [3/8,5/8]);
	fx
});
~p[\fx1].play(vol:1);
~p[\fx1].stop;
~p[\fx1].gui;

/////////////////////////////////////////
// fx2
~p[\fx2].clear;
(~p[\fx2][0] = {

	var fx;
	var in = ~p[\chord].ar;
	fx = RLPF.ar( (in).fold(-0.5, 0.5), SinOsc.kr( SinOsc.kr(1/4).range(1,5) ).range(440, 3200), 0.2);
	fx;
});
~p[\fx2].play(vol:1);
~p[\fx2].stop;
~p[\fx2].gui;


/////////////////////////////////////////
// chord2
~p[\chord2].clear;
~p[\chord2].mold;
(~p[\chord2][0] = Pbind(
	\instrument, \s1,
	\scale, Scale.chromatic,
	\octave, Pseq([5, 6], inf),
	\pan, 0,
	\detune, Pwhite(-1.0, 1.0),
	\degree, 0,
	\dur, 2,
	\sustain, 0.5
));
~p[\chord2].play(vol:5);
~p[\chord2].stop;
~p[\chord2].gui;

App.recordWorkspace("ws8");
s.stopRecording