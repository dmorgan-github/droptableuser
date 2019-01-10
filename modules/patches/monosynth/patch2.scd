Pdef.defaultQuant = 1.0;


(
~patch2 = {arg key;

	Ndef(key, {

		var trig = \trig.tr;
		var freq = Vibrato.kr(\freq.kr(432).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0));

		var mod = {arg freq, trig;

			var	modratio = \modratio.kr(2);
			var modenvhi = \modenvhi.kr(3);
			var modenvlo = \modenvlo.kr(0.01);
			var modenvdur = \modenvdur.kr(1);
			var modenvcurve = \modenvcurve.kr(4);

			var modindex = freq * modratio
			* Env([modenvhi, modenvhi, modenvlo], [0, modenvdur], modenvcurve).kr(gate:trig);

			var mod = SinOsc.ar(freq * modratio) * modindex;
			mod * \fm.kr(0);

		};

		var env = {arg trig;
			var suslevel = \suslevel.kr(0.7);
			Env(
				[0,1,suslevel,suslevel,0],
				[\atk.kr(0.001), \dec.kr(0.01), \sus.kr(0), \rel.kr(1)],
				curve:\curve.kr(-4)
			).kr(gate:trig);
		}.(trig);

		var vcos = [
			{
				var freqmult = \vco1_freqmult.kr(1);
				var width = \vco1_width.kr(0.5);
				var myfreq = freq * freqmult;
				var mymod = mod.(myfreq, trig);
				var sig = Pulse.ar(myfreq + mymod, width: width);
				sig;
			}
		].collect(_.());

		var which = 0; //\which.kr(1) - 1;
		var focus = 1;//\focus.kr(1);
		var sig = LeakDC.ar(SelectXFocus.ar(which, vcos, focus, true));

		var filt = {arg sig, trig;

			var which = \filt_which.kr(0);
			var focus = \filt_focus.kr(1);

			var hipass = {arg sig;
				var center = \hpf.ar(1200);
				var res = \hpf_res.kr(0).linlin(0,1,1,0);
				var rate = \hpf_rate.kr(1);
				var range = \hpf_range.kr(1);
				var min = center * range.reciprocal;
				var max = center * range;
				BHiPass.ar(sig, SinOsc.kr(rate).range(min, max).clip(20, 20000), res)
			};

			var bandpass = {arg sig;
				var center = \bpf.ar(1200);
				var bw = \bpf_bw.kr(0.1).linlin(0,1,0,10);
				var rate = \bpf_rate.kr(1);
				var range = \bpf_range.kr(1);
				var min = center * range.reciprocal;
				var max = center * range;
				BBandPass.ar(sig, SinOsc.kr(rate).range(min, max).clip(20, 20000), bw)
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

			var filts = [
				lopass.(sig),
				bandpass.(sig),
				hipass.(sig)
			];

			SelectXFocus.ar(which, filts, focus, true);
		};

		sig = sig.blend(filt.(sig, trig), \filt_wet.kr(1));
		sig = sig * env * AmpCompA.kr(freq) * \amp.kr(-6.dbamp);
		sig = Splay.ar(sig, spread:1, center: 0);

		sig = sig.blend(SoftClipAmp8.ar(sig, \pregain.kr(1)), \dist_wet.kr(0));

		sig = sig.blend(
			FbC({arg fb; fb * \del_fb.kr(0.3) + sig}, 2, [\del_l.kr(2/16), \del_r.kr(3/16)] * \beat_dur.kr(1)),
			\del_wet.kr(0.4)
		);
		sig = sig.blend(
			JPverb.ar(HPF.ar(sig, \rev_hpf.kr(100)), \rev_t60.kr(3), 0, \rev_size.kr(5)),
			\rev_wet.kr(0.3)
		);

		sig;
	});

	Pdef(key,
		Pdef(\nbind) <> (node:Ndef(key))
		<> Pbind(*Ndef(key)
			.controlNames
			.reject({arg ctrl; (ctrl.name == \freq) || (ctrl.name == \trig)})
			.collect({arg ctrl; [ctrl.name, ctrl.defaultValue]}).flatten)
	)
};

~patch2.(\p2_s1);
)


Pdef(\p2_s1).play;
Pdef(\p2_s1).stop;

(
Pdef(\p2_s1_v1,
	Pchain(
		Pbind(

			\octave, 6,
			\scale, Scale.aeolian,
			\degree, Pseq([0, 3, -2, 7], inf),

			\amp, -12.dbamp,
			\dur, 0.25,
			\rel, 0.3,

			// lpf
			\lpf, Pfunc({arg evt; evt[\freq]}) * 1.5,
			\lpf_res, 0.5,
			\lpf_rate, 1/4 * Pkey(\beat_dur),
			\lpf_range, 2,

			// bpf
			\bpf, Pfunc({arg evt; evt[\freq]}),
			\bpf_bw, 0.2,
			\bpf_rate, 13,
			\bpf_range, 3,

			// hpf
			\hpf, Pfunc({arg evt; evt[\freq]}) * 0.5,
			\hpf_res, 0.2,

			// mix filters
			\filt_which, 0,
			\filt_focus, 0.7,
			\filt_wet, 1,

			// fm
			\fm, 0.0,
			\modenvdur, 1,
			\modratio, 2.01,
			\modenvhi, 3,
			\modenvlo, 0.01,
			\modenvcurve, -4,

			// delay
			\del_l, 3/8,
			\del_r, 3/16,
			\del_fb, 0.5,
			\del_wet, 0.4,

			// reverb
			\rev_wet, 0.3,
			\rev_t60, 5,

			// distortion
			\dist_wet, 0.5,
			\pregain, 1.1
		),

		Pdef(\p2_s1),
	)
)
)

Pdef(\p2_s1_v1).play;
Pdef(\p2_s1_v1).stop;

App.saveWorkspace("ws7", rec:true);
s.stopRecording
