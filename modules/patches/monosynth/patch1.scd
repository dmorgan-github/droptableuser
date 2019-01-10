(
~patch1 = {arg key;

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
};

~patch1.(\s4);
~patch1.(\s5);
~patch1.(\s6);
)

/////////////////////////////////////////
// s4
Pdef(\s4).play;
Pdef(\s4).stop;

(
Pdef(\s4_v1,
	Pchain(

		Pbind(\amp, Pseq([1] ++ (0.7!7), inf) * 0.dbamp),

		Pbind(\fm, 1, \modratio,  (12 * 2 + 7).midiratio ),

		Pbind(\vco1_freqmult, 12.midiratio),

		Pbind(\vco2_freqmult, 14.2.midiratio),

		Pbind(\vco3_freqmult, 0.2.midiratio),

		Pbind(\vco4_freqmult, 2, \vco4_rq, 0.01, \vco4_ampcomp, 0.3),

		Pbind(\fcenter, Pfunc({arg evt; evt[\freq] * 1}), \fwidth, 2, \res, 0.3),

		Pbind(\rel, Pif(Pfunc({arg evt; evt[\which] == 4}), 0.15, 1)),

		//Pbind(\which, Ppoisson(1, inf).stutter(2) + 1),
		Pbind(\which, Pseq([
			Pseq(1!8, 8),
			Pseq([1,1,1,1,1,1,1,1,2,2,3,3,3,4,4,4], 4),
		], inf)),
		//Pbind(\which, 4),

		Pbind(\focus, Pwhite(0.8, 1.0, inf)),//Pwhite(0.3, 0.8, inf)),

		Pbind(\octave, 5),

		//Pbind(\scale, Scale.aeolian),
		Pbind(\scale, Pseq([
			Pn(Scale.chromatic, 96),
			Pn(Scale.aeolian, 64)
		], inf)),//Pseq([Scale.chromatic, Scale.aeolian], inf).stutter(512)),

		Pbind(\degree, Pseq([0, 3, -2, 7], inf)),

		Pbind(\dur, 0.25),

		Pbind(
			\del_wet, 0.5,
			\del_l, 3/8,
			\del_r, 5/8
		),

		Pbind(
			\rev_wet, 0.2,
			\rev_t60, 7,
			\rev_size, 5
		),

		Pbind(
			\dist_wet, 0.2,
			\pregain, 3,
		),

		Pdef(\s4)
	)
)
)

Pdef(\s4_v1).play;
Pdef(\s4_v1).stop;

Pbind(\fcenter, 1000, \fwidth, 2, \res, 0.1)
Pbind(\fcenter, 1000, \fwidth, 1.5, \res, 0.2)
Pbind(\fcenter, Pfunc({arg evt; evt[\freq]}), \fwidth, 1.5, \res, 0.8)
Pbind(\fcenter, Pfunc({arg evt; evt[\freq]/2}), \fwidth, 1.5, \res, 0.8);

TempoClock.default.tempo_(55/60)


/////////////////////////////////////////
// s5
Pdef(\s5).play;
Pdef(\s5).stop;

(
Pdef(\s5_v1,
	Pchain(

		Pbind(\amp, -6.dbamp),

		Pbind(\which, 2),

		Pbind(\focus, 0.5),

		Pbind(\fcenter, Pfunc({arg evt; evt[\freq] * 0.6}), \fwidth, 1.5, \res, 0.1),

		Pbind(\fm, 1, \modratio, 4.5),

		Pbind(\fatk, 3, \frel, 4),

		Pbind(\vco1_freqmult, 2),

		Pbind(\vco2_freqmult, 1.5),

		Pbind(\vco3_freqmult, 4),

		Pbind(\atk, 1, \sus, 3, \rel, 3),

		Pbind(\dur, 7),

		Pbind(\scale, Scale.chromatic),

		Pbind(\octave, 5),

		Pbind(\degree, Pseq([0, 3, -2, 7], inf)),

		Pbind(
			\del_wet, 0.5,
			\del_l, 1/4,
			\del_r, 1/2
		),

		Pbind(
			\rev_wet, 0.6,
			\rev_t60, 10,
			\rev_size, 5
		),

		Pbind(
			\dist_wet, 0.8,
			\pregain, 3,
		),

		Pdef(\s5)
	)
)
)
Pdef(\s5_v1).play;
Pdef(\s5_v1).stop;


/////////////////////////////////////////
// s6
Pdef(\s6).play;
Pdef(\s6).stop;

(
Pdef(\s6_v1,
	Pchain(

		Pbind(\amp, -12.dbamp),

		Pbind(\which, Pwhite(2,3,inf)),

		Pbind(\focus, 0.8),

		Pbind(\fcenter, Pfunc({arg evt; evt[\freq] * 1.5}), \fwidth, 2, \res, 0.1),

		Pbind(\fm, 1, \modratio, 4.0),

		Pbind(\fatk, 3, \frel, 4),

		Pbind(\vco1_freqmult, 1),

		Pbind(\vco2_freqmult, 1.5),

		Pbind(\vco3_freqmult, 1),

		Pbind(\vco4_freqmult, 2),

		Pbind(\atk, 1, \sus, 3, \rel, 3),

		Pbind(\dur, 11),

		Pbind(\scale, Scale.chromatic),

		Pbind(\octave, 4),

		Pbind(\degree, Pseq([0, 3, -2, 7], inf)),

		Pbind(
			\del_wet, 0.5,
			\del_l, 1/4,
			\del_r, 1/2
		),

		Pbind(
			\rev_wet, 0.6,
			\rev_t60, 10,
			\rev_size, 5
		),

		Pbind(
			\dist_wet, 0.8,
			\pregain, 3,
		),

		Pdef(\s6)
	)
)
)
Pdef(\s6_v1).play;
Pdef(\s6_v1).stop;


(
Pdef(\ps,
	Pspawner({arg ps;

		var s4, s5, s6, p2_s1, p3_s1;

		p2_s1 = ps.par(Pdef(\p2_s1_v1));

		ps.wait(32);

		"here1".postln;

		s4 = ps.par(Pdef(\s4_v1));

		ps.wait(16);

		"here2".postln;
		s5 = ps.par(Pdef(\s5_v1));
		s6 = ps.par(Pdef(\s6_v1));

		ps.wait(64);

		"here3".postln;
		s4.stop;
		s5.stop;
		s6.stop;
		p2_s1.stop;

		ps.wait(4);

		"here4".postln;
		p2_s1 = ps.par(Pchain(Pbind(\octave, Pseq([4], inf).stutter(512)), Pdef(\p2_s1_v1)));
		s4 = ps.par(Pdef(\s4_v1));
		s5 = ps.par(Pdef(\s5_v1));
		s6 = ps.par(Pdef(\s6_v1));
		p3_s1 = ps.par(Pdef(\p3_s1_v1));

		ps.wait(64);

		"here5".postln;
		s4.stop;
		s5.stop;
		s6.stop;
		p2_s1.stop;
		p3_s1.stop;

	})
)
)

App.saveWorkspace("ws7", rec:true);
Pdef(\ps).play;
Pdef(\ps).stop;
s.stopRecording;



(
Ppar([
	Pchain(Pbind(\octave, Pseq([4], inf).stutter(512)), Pdef(\p2_s1_v1)),
	Pdef(\s4_v1),
	Pdef(\s5_v1),
	Pdef(\s6_v1),
	Pdef(\p3_s1_v1)
]).play
)

