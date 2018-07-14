/*
Requires sc3-plugins: DFM1, Greyhole, JPverb
*/

///////////////////////////////////////////////
// 1: setup
(
SynthDef(\s1, {

	var trig = \trig.tr;
	var dur = \dur.kr(1);
	var amp = \amp.kr(0.1);

	var freq = {

		var lag = \lag.kr(0.0);
		var freq = \freq.kr(220).lag(lag);
		var rate = \rate.kr(6);
		var depth = \depth.kr(0.02);
		var delay = \delay.kr(0);
		var onset = \onset.kr(0.0);
		var rateVariation = \rateVar.kr(0.04);
		var depthVariation = \depthVar.kr(0.1);
		var iphase = 0;

		Vibrato.ar(K2A.ar(freq),
			rate:rate, depth:depth,
			delay:delay,
			onset:onset,
			rateVariation:rateVariation,
			depthVariation:depthVariation,
			iphase:0,
			trig: trig);
	}.();

	var sig = {

		var phase = \sinphase.kr(0);
		var pwidth = \pwidth.kr(0.5);
		var swidth = \swidth.kr(0.5);
		var sin_freq_mul = \sin_freq_mul.kr(1);
		var varsaw_freq_mul = \varsaw_freq_mul.kr(1);
		var saw_freq_mul = \saw_freq_mul.kr(1);
		var pulse_freq_mul = \pulse_freq_mul.kr(1);

		var sin = SinOsc.ar(freq * sin_freq_mul, phase, mul:\sin_amp.kr(1));
		var varsaw = VarSaw.ar(freq * varsaw_freq_mul, 0, swidth, mul:\varsaw_amp.kr(0));
		var saw = Saw.ar(freq * saw_freq_mul, mul:\saw_amp.kr(0));
		var pulse = Pulse.ar(freq * pulse_freq_mul, pwidth, mul:\pulse_amp.kr(0));

		Mix.ar([sin, varsaw, saw, pulse]);

	}.();

	var env = {

		var atk = \atk.kr(0.01);
		var sus = \sus.kr(0);
		var rel = \rel.kr(0.9);

		Env([0, 0, 1, 1, 0],[0, atk, sus, rel], [-4,4] ).kr(gate:trig, timeScale: dur);

	}.();

	sig = DFM1.ar(sig, freq * \dfm1_freq_mul.kr(3), \dfm1_res.kr(0.1));

	sig = sig * env * AmpCompA.kr(freq) * amp;

	sig = Pan2.ar(sig, \pan.kr(0));

	Out.ar(\out.kr(0), sig);

}).add;

~s1 = NodeProxy.audio;

~s1[0] = Pmono(\s1,
	\trig, 1,

	// rhythm
	\delta, 4,
	\dur, Pkey(\delta),

	// freq
	\octave, Prand([4,5,6], inf),
	\degree, Pbrown(0, 4, 1, inf),

	// oscs
	\sin, 1.0,
	\varsaw, 0.5,
	\pulse, 0.0,
	\saw, 0.0,

	\pwidth, 0.0,
	\swidth, 0.0,

	// harms
	\sin_freq_mul, 1,
	\varsaw_freq_mul, 2.0145,

	// env
	\env_atk, 1,
	\env_sus, 1.0,
	\env_rel, 2,

	// vib
	\rate, 5,
	\depth, 0.01,

	// amp
	\amp, 0.1,
	\pan, Pwhite(-0.5, 0.5),

	\dfm1_res, Pwhite(0.1, 0.9, inf),
	\dfm1_freq_mul, Pwhite(2.0, 4.0, inf),

	// controls
	[\atk, \sus, \rel], Pfunc({arg evt; [evt[\env_atk], evt[\env_sus], evt[\env_rel]].normalizeSum; }).collect(`_),
	[\sin_amp, \varsaw_amp, \pulse_amp, \saw_amp], Pfunc({arg evt; [evt[\sin], evt[\varsaw], evt[\pulse], evt[\saw]].normalizeSum; }).collect(`_),
);

~s1[20] = \filter -> {arg in;

	in = (in * 0.5) + Greyhole.ar(in * 0.2, modDepth:0.3);
	in = in + JPverb.ar(in, 2, 0.9, 5, modDepth:1);
	in;
};
)

///////////////////////////////////////////////
// 2: play
(
TempoClock.default.tempo_(0.7);
~s1.play(fadeTime:5);
)

///////////////////////////////////////////////
// 3: stop
~s1.stop(fadeTime:15)