(
Fdef(\filtpulse1, {arg key;

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

		var sig = vcos;

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
});
)