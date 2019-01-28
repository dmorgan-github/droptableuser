(
Fdef(\four1, {arg key;

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

		}.(freq, trig);

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
				var sig = SinOsc.ar(freq * freqmult + mod);
				sig;
			},
			{
				var freqmult = \vco2_freqmult.kr(1);
				var width = \vco2_width.kr(0.5);
				var sig = VarSaw.ar(freq * freqmult, width: width);
				sig;
			},
			{
				var freqmult = \vco3_freqmult.kr(1);
				var sync = \vco3_sync.kr(1.5);
				var myfreq = freq * freqmult;
				var sig = SyncSaw.ar(myfreq, myfreq * sync);
				sig;
			},
			{
				var freqmult = \vco4_freqmult.kr(1);
				var sig = RLPF.ar(WhiteNoise.ar, freq * freqmult, \vco4_rq.kr(0.01));
				sig * \vco4_ampcomp.kr(1);
			}
		].collect(_.());

		var which = \which.kr(1) - 1;
		var focus = \focus.kr(1);
		var sig = LeakDC.ar(SelectXFocus.ar(which, vcos, focus, true));

		var filtenv = {arg trig;
			var width = \fwidth.kr(1);
			var center = \fcenter.kr(1000);
			var hi = center * width;
			var lo = center * width.reciprocal;
			var fenv = Env.perc(\fatk.kr(0.01), \frel.kr(1), curve:\fcurve.kr(-4)).kr(gate:trig, timeScale:\fts.kr(1));
			fenv.exprange(lo, hi).clip(20, 20000);
		};

		var moog = {arg sig, trig;
			var fenv = filtenv.(trig);
			var res = \res.kr(0.1);
			MoogFF.ar(sig, fenv, res.linlin(0,1,0,4));
		};

		sig = moog.(sig, trig);
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



