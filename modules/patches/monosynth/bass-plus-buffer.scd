(
~s1 = {arg key;

	Ndef(key, {

		var trig = \trig.tr;
		var fundamental = Vibrato.kr(\freq.kr(432).lag(\lag.kr(0.1)), \vrate.kr(6), \vdepth.kr(0));
		var freqmult = \freqmult.kr(1.5);
		var mod = Fdef(\mod).(fundamental, trig);

		var sig = (
			[
				SyncSaw.ar(fundamental * [1, 1.01] + mod, fundamental * freqmult),
				VarSaw.ar(fundamental + mod, 0, LFNoise2.kr(1/4).range(0.2, 0.8)),
				WhiteNoise.ar();
			] * [\vco1mix.kr(1), \vco2mix.kr(0.2), \noisemix.kr(0.1)].normalizeSum
		).sum;

		var env = Env([0,1,0.7,0.7,0],[\atk.kr(0.001), \dec.kr(0.01), \sus.kr(0), \rel.kr(1)], curve:\curve.kr(-4)).kr(gate:trig);
		var fcenter = \fcenter.kr(1000);
		var fdepth = \fdepth.kr(0);
		var fmin = fcenter + (fcenter * fdepth).neg;
		var fmax = fcenter + (fcenter * fdepth);
		var ffreq = env.range(fmin, fmax).clip(20, 20000);
		var res = \res.kr(0.5).linlin(0,1,0,4);
		var amp = \amp.kr(-6.dbamp);

		sig = sig.blend(FbC({arg fb; PitchShift.ar(fb, 0.2, 1.5, 0.01, 0.01)  * 0.90 + sig}, 0.1), \fb.kr(0.3));
		sig = sig * env * AmpCompA.kr(fundamental) * amp;

		sig = MoogFF.ar(sig, ffreq, res);
		sig = SoftClipAmp8.ar(sig, \overdrive.kr(2));
		sig = LPF.ar(sig, \lpf.kr(4440));
		sig = LeakDC.ar(sig);
		sig = sig.blend(FbC({arg fb; fb * 0.3 + sig}, [3/4, 3/3.3]), 0.2);
		sig = sig.blend(JPverb.ar(sig, 5, 0, 5), 0.2);

		sig;
	});

	Pdef(key,
		Pdef(\nbind) <> (node:Ndef(key)) <> Pbind(
			\dur, 0.25,
			\amp, -6.dbamp,
			\fdepth, Prand([0.5, 1, 2, 0.1], inf),
			\res, Pwhite(0.1, 0.7, inf),
			\freqmult, Pwhite(1.01, 1.7, inf),
			\octave, Pbjorklund(7, 11, inf).collect({arg val; if (val == 1) { [5,6].choose }{4}}),
			\degree, Ppatlace([ Pseq([0,7], inf), Pseq([1,2,4,5], inf) ], inf ),
			\rel, Pwhite(0.2, 1, inf),
			\curve, Pwhite(-14.0, 14.0, inf),
			\overdive, Pstutter(16, Pwhite(-2.0, 3.0, inf)),
			\lpf, Pstutter(32, Pwhite(880, 4440, inf)),
			\noisemix, Pwhite(0.1, 0.5, inf),
			\vco2mix, Pwhite(0.2, 0.8, inf),
			\lag, Pwhite(0.001, 0.01, inf),
			\fm, Pstutter(4, Pwhite(0.1, 1.0, inf)),
			\modenvhi, Pwhite(1.0, 6.0, inf),
			\modenvcurve, Pwhite(-4.0, 4.0, inf),
			\fcenter, Pkey(\freq) * Pwhite(1.0, 3.0, inf),
		)
	)
};
~s1.(\t1);
)

q = ();
q[\b] = ()
q[\b][\b5] = Buffer.alloc(s, 44100 * 16, 2);

(
~s2 = {arg key;

	var buf = q[\b][\b5];
	var numFrames = buf.numFrames;
	var dur = buf.duration;

	Ndef(key, {

		var buf = \buf.kr;

		var foo = {
			var sig = Ndef(\t1).ar;
			RecordBuf.ar(sig, buf, recLevel:1);
		}.();

		var trig = \trig.tr;
		var numChannels = 2;
		var rate = \rate.kr(1);
		var startPos = \pos.kr(0);
		var loop = \loop.kr(0);
		var dur = \dur.kr(1);
		var sig = PlayBufCF.ar(numChannels, buf, rate, trig, startPos, loop);
		var env = Env([0,1,1,0], [0.01, dur, 0.01], curve:\step).kr(gate:trig);
		sig = sig * env * \amp.kr(-12.dbamp);

		sig = sig.blend( FbC({arg fb; fb * 0.7 + sig}, 0.2), 0.3 );

		sig = sig.blend(JPverb.ar(sig, 5, 0, 5), 0.4);

		sig = sig.blend(Squiz.ar(sig, [1.5,2], LFNoise1.kr(1/4).range(1, 30)), 0.1);

		sig = Rotate2.ar(sig[0], sig[1], LFTri.kr(1/4));

		sig;
	});

	Pdef(key,
		Pdef(\nbind) <> (node:Ndef(key)) <> Pbind(
			\buf, Pfunc({buf}),
			\foo, Pseg([0, numFrames], [dur], 0, inf).collect({arg val; if (0.7.coin){val}{Rest()}}),
			\pos, Pkey(\foo),
			\delta, 0.5,
			\dur, Pkey(\delta) * Pwhite(0.5, 2.0, inf),
			\bar, Pxrand([12,7,5,14].midiratio, inf),
			\rate, Pfunc({arg evt; if (0.6.coin) {1}{-1} * if (0.7.coin) {1} {evt[\bar]} }),
			\amp, -4.dbamp
		)
	)
};
~s2.(\t2);
)

(
Pdef(\t1_2,
	Pbind(
		\mtranspose, 0,
		\scale, Scale.dorian,
		//\fm, 0.2,
		//\modenvcurve, 24,
		//\fb, 0.2,
		\octave, 4,
		//\degree, Pseq([0,1,3,5], inf),
		\dur, 8,
		\atk, 2,
		\rel, Pkey(\dur) * 0.5,
		\sus, Pkey(\dur) * 0.5,
		//\freqmult, 1.5,
		//\noisemix, 0.5,
		//\vco1mix, 1,
		//\vco2mix, 0.1
	) <> Pdef(\t1)
)
)

Pdef(\t1_2).play;
Pdef(\t1_2).stop;

Pdef(\t1_2).play;
Pdef(\t2).play;

Ndef(\t2).fadeTime = 10;

Ndef(\t2).stop(fadeTime:10);
Pdef(\t2).stop;


App.saveWorkspace("ws6", rec:true);
s.stopRecording

