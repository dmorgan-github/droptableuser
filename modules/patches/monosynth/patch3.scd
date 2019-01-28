SynthDef(\resonz, { |out, freq = 440|
    var    sig, ffreq;
    sig = Mix.ar(Saw.ar([freq, freq+1, freq * 7.midiratio], 0.2));
    ffreq = LFNoise1.kr(2, 0.5, 1);
    Out.ar(out, Mix.ar(Resonz.ar(sig, (800, 1000..1800) * ffreq, 0.1)))
}).add

a = Synth(\resonz);
a.trace;
a.free;

Library.at(\bufs, \p3_s3).numChannels

(
Fdef(\patch3, {arg key, path;

	var numChannels = 1;
	var buf = Library.at(\bufs, key);
	var load;
	if (buf.isNil) {
		Buffer.read(s, path, action:{arg buffer;
			Library.put(\bufs, key, buffer);
			load.(buffer);
		});
	} {
		if (buf.path != path) {
			if (buf.path.isNil.not) {
				buf.free;
			};
			Buffer.read(s, path, action:{arg buffer;
				Library.put(\bufs, key, buffer);
				load.(buffer);
			});
		} {
			load.(buf);
		}
	};

	load = {arg buf;

		numChannels = buf.numChannels;

		Ndef(key)[0] = {

			var trig = \trig.tr(0);
			var buf = \buf.kr;
			var rate = \rate.kr(1);
			var frames = BufFrames.kr(buf);
			var start = \start.kr(0) * frames;
			var end = \end.kr(1) * frames;
			var dur = ((end-start)/44100) * rate.reciprocal;

			var hipass = {arg sig;
				var center = \hpf.ar(1200);
				var res = \hpf_res.kr(0).linlin(0,1,1,0);
				var rate = \hpf_rate.kr(1);
				var range = \hpf_range.kr(1);
				var min = center * range.reciprocal;
				var max = center * range;
				BHiPass.ar(sig, SinOsc.kr(rate).range(min, max).clip(20, 20000), res)
			};

			var lopass = {arg sig;
				var center = \lpf.ar(1200);
				var res = \lpf_res.kr(0).linlin(0,1,1,0);
				var rate = \lpf_rate.kr(1);
				var range = \lpf_range.kr(1);
				var min = center * range.reciprocal;
				var max = center * range;
				BLowPass.ar(sig, SinOsc.kr(rate).range(min, max).clip(20, 20000), res)
			};

			var phase = Env([0, start, end],[0, dur], \warp.kr(0)).ar(gate:trig);
			var sig = BufRd.ar(numChannels, buf, phase, interpolation:4);

			//var env = Env.linen(0, 1, 0).kr(gate:trig, timeScale:dur);
			sig = sig.blend(FreqShift.ar(sig, [\fshift_freq_l.kr(0), \fshift_freq_r.kr(0)]), \fshift_mix.kr(0));

			sig = sig.blend(sig ring1: SinOsc.ar(1800), \ring_mix.kr(0));

			sig = sig.blend(SoftClipAmp8.ar(sig, \pregain.kr(1)), \dist_mix.kr(0));

			sig = sig.blend(Decimator.ar(sig, \dec_rate.kr(44100), \dec_bits.kr(24)), \dec_mix.kr(0));

			sig = sig.blend(
				FbC({arg fb; fb * \del_fb.kr(0.3) + sig},
					2,
					[\del_l.kr(3/4), \del_r.kr(4/4)] * \beat_dur.kr(1)
				),
				\del_mix.kr(0)
			);

			sig = sig.blend(Squiz.ar(sig, \pitchratio.kr(2), \zcperchunk.kr(1)), \squiz_mix.kr(0));

			sig = sig.blend(lopass.(hipass.(sig)), \filt_mix.kr(0));

			sig = sig.blend(JPverb.ar(sig, \rev_t60.kr(1), 0, \rev_size.kr(1)), \rev_mix.kr(0));

			sig = sig * \amp.kr(-12.dbamp);
			Splay.ar(sig, \spread.kr(1), 1, \center.kr(0));
		};

		Pdef(key,
			Pdef(\nbind) <> (node:Ndef(key))
			<> Pbind(\buf, Pfunc({buf}))
			<> Pbind(*Ndef(key)
				.controlNames
				.reject({arg ctrl; (ctrl.name == \freq) || (ctrl.name == \trig)})
				.collect({arg ctrl; [ctrl.name, ctrl.defaultValue]}).flatten)
		)
	}
});
Fdef(\patch3).(\p3_s1, "/Users/davidmorgan/git/droptableuser/samples/1channel/drums/perc1/djembe/djembe_low.wav");
Fdef(\patch3).(\p3_s2, "/Users/davidmorgan/git/droptableuser/samples/1channel/drums/perc2/triangle/triangle-classical.wav");
)

Pdef(\p3_s1).play;
Pdef(\p3_s1).stop;

(
Pdef(\p3_s1_v1,
	Pchain(
		Pbind(
			\dur, Prand([0.25, 0.5, 1], inf),
			\amp, Pwhite(0.2, 1.0, inf) * -6.dbamp,
			\warp, Pwhite(-4, 4, inf),
			\rate, 1,

			\fshift_mix, 0.5,
			\fshift_freq_l, -100,
			\fshift_freq_r, 100,

			\dist_mix, 0,
			\pregain, 3,

			\squiz_mix, 0.1,
			\zcperchunk, Pwhite(2.0, 30.0, inf),
			\pitchratio, 4,

			\del_mix, 0.4,
			\del_l, 3/8,
			\del_fb, 0.7,

			\ring_mix, 0,

			\rev_mix, 0.3,
			\rev_t60, 5,
			\rev_size, 5
		),
		Pdef(\p3_s1)
	)
)
)

Pdef(\p3_s1_v1).play;
Pdef(\p3_s1_v1).stop;


//////////////////////////////////////////////////
Pdef(\p3_s2).play;
Pdef(\p3_s2).stop;

(
Pdef(\p3_s2_v1,
	Pchain(
		Pbind(
			\dur, 4,

			\rate, 2,
			\amp, -25.dbamp,
			\warp, 4,

			\fshift_freq_l, -100,
			\fshift_freq_r, 100,

			\del_mix, 0.5,
			\del_l, 3/4,
			\del_fb, 0.7,

			\rev_mix, 0.5
		),
		Pdef(\p3_s2)
	)
);
)

Pdef(\p3_s2_v1).play;
Pdef(\p3_s2_v1).stop;

//////////////////////////////////////////////////
Fdef(\patch3).(\p3_s3, "/Volumes/Backup/supercollider/samples2/Dirt-Samples/ho/HHOD0.wav");
Fdef(\patch3).(\p3_s3, "/Volumes/Backup/supercollider/samples2/Dirt-Samples/glitch/000_BD.wav");
Fdef(\patch3).(\p3_s3, "/Volumes/Backup/supercollider/samples2/Dirt-Samples/drum/000_drum1.wav");
Fdef(\patch3).(\p3_s3, "/Volumes/Backup/supercollider/samples2/Dirt-Samples/incoming/005_Mattel Tom High.wav");

Pdef(\p3_s3).play;
Pdef(\p3_s3).stop;

(
Pdef(\p3_s3_v1,
	Pchain(
		Pbind(
			\dur, 2,
			\amp, Pwhite(0.3, 1.0, inf) * -8.dbamp,
			\warp, 0,

			\dec_rate, 44100/8,
			\dec_bits, 8,
			\dec_mix, 0,

			\squiz_mix, 0.5,
			\zcperchunk, Pwhite(1, 30, inf),

			\del_mix, 1,
			\del_l, 3/4 * Pkey(\beat_dur),
			\del_r, 4/4 * Pkey(\beat_dur),

			\rev_mix, 0.3
		),
		Pdef(\p3_s3)
	)
)
)

Pdef(\p3_s3_v1).play;
Pdef(\p3_s3_v1).stop;

//////////////////////////////////////////////////
Fdef(\patch3).(\p3_s4, "/Volumes/Backup/supercollider/samples2/Dirt-Samples/ade/003_abt.wav");

Pdef(\p3_s4).play;
Pdef(\p3_s4).stop;

(
Pdef(\p3_s4_v1,
	Pchain(
		Pbind(
			\dur, 1,
			\rev_mix, 0.4
		),
		Pdef(\p3_s4)
	)
)
)

Pdef(\p3_s4_v1).play;
Pdef(\p3_s4_v1).stop;

//////////////////////////////////////////////////
Fdef(\patch3).(\p3_s5, "/Volumes/Backup/supercollider/samples2/Dirt-Samples/ade/001_011112-melody.wav");

(
Pdef(\p3_s5_v1,
	Pchain(
		Pbind(
			\dur, 2,
			\amp, 0.dbamp,
			\rev_mix, 0.7
		),
		Pdef(\p3_s5)
	)
)
)

Pdef(\p3_s5_v1).play;
Pdef(\p3_s5_v1).stop;

/////////////////////////////////////////////////
Fdef(\patch3).(\p3_s6, "/Volumes/Backup/supercollider/samples2/Dirt-Samples/ade/006_glass.wav");

Pdef(\p3_s6_v1).clear;
(
Pdef(\p3_s6_v1,
	Pchain(
		Pbind(
			\dur, 5,
			\amp, -12.dbamp,

			\del_mix, 0.7,
			\del_fb, 0.5,

			\rev_mix, 0.7,
		),
		Pdef(\p3_s6)
	)
)
)

Pdef(\p3_s6_v1).play;

/////////////////////////////////////////////////
Fdef(\patch3).(\p3_s7, "/Volumes/Backup/supercollider/samples2/Dirt-Samples/ade/008_rhythm.wav");

(
Pdef(\p3_s7_v1,
	Pchain(
		Pbind(
			\dur, 5,
			\amp, -12.dbamp,

			\del_mix, 0.7,
			\del_fb, 0.5,

			\rev_mix, 0.7,
		),
		Pdef(\p3_s7)
	)
)
)

Pdef(\p3_s7_v1).play;
Pdef(\p3_s7_v1).stop;





s.record;
s.stopRecording;