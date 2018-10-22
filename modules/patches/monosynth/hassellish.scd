(
~p[\harm][0] = {

	var trig = \trig.tr;

	var freq = \freq.kr(300);

	var fb = \fb.kr(0.5);

	var lag = \lag.kr(0.0);

	var dur = \dur.kr(1);

	var ffreq;

	//var modSig, cutoffBase = 500, cutoffMod = 2000;

	var midi = Vibrato.ar( K2A.ar(freq), 3, 0.01, 0, 0.2, 0.1, 0.7 ).cpsmidi;

	var harms = midi + \harms.kr([3,7]);

	var cps = ([midi] ++ harms).midicps;

	var sig = SinOscFB.ar(cps.lag(lag), fb, mul: AmpCompA.kr(cps) );

	var env = Env([0, 0, 1, 0.8, 0], [0, 0.05, 2, 1].normalizeSum, [4,-4]).kr(gate: trig, timeScale: dur);

	sig = sig * env * \amp.kr(0.1);

	sig = AllpassC.ar(sig, add: sig);

	// TODO: figure this filter out
	ffreq = LinExp.kr(LFNoise1.kr(0.1), -1, 1, 440, 2000);

	sig = BLowPass.ar(sig, ffreq, \rq.kr(0.4) );

	sig = XFade2.ar(sig, Greyhole.ar(sig, feedback:0.5), -0.5);

	sig = GVerb.ar(sig,
		\roomsize.kr(40),
		\revtime.kr(20),
		\damping.kr(0.50),
		\inputbw.kr(0.75),
		\spread.kr(15),
		\drylevel.kr(1),
		\earlyreflevel.kr(0.31622776601684),
		\taillevel.kr(0.03162277660168)
	);

	sig;
};
)

/*
~harm.addSpec(\cutoff, \freq.asSpec);
~harm.addSpec(\rq, \amp.asSpec);
~harm.addSpec(\lowpass, \amp.asSpec);
~harm.addSpec(\bandpass, \amp.asSpec);
~harm.addSpec(\highpass, \amp.asSpec);
~harm.addSpec(\notch, \amp.asSpec);
~harm.addSpec(\peak, \amp.asSpec);
~harm.gui
*/

// "http://makenoisemusic.com/content/manuals/telharmonicManual.pdf"

(
~p[\harm][10] = \set -> PbindProxy(
	\args, [\freq, \trig, \harms, \lag, \dur, \fb],
	\root, 2,
	\trig, 1,
	\degree, Pbrown(0, 3, 1, inf),
	\octave, Pstutter(2, Prand([5,6], inf)),
	\scale, Scale.zhi.tuning_(\just),
	\harms, Pseq([ [2, 7], [-5, 5], [-2, -7] ], inf).collect(`_),
	\lag, 0.1,
	\fb, Pwhite(0.4, 0.6, inf),
	\delta, Pbjorklund2(3, 8, inf),
	\dur, Pkey(\delta),
	\amp, Pexprand(0.1, 0.2, inf)
)
)

~p[\harm].vol = 0.3
~p[\harm].play(vol:0.5);
~p[\harm].stop(fadeTime:5);

App.record
s.stopRecording

