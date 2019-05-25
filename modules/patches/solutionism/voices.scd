(
Library.put(\voices, \varsaw, {arg cb={arg sig; sig};
	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		var glide = \glide.kr(0) > 0;
		var gate = Trig1.kr(trig, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.3),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(1),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
		).kr(gate:gate);

		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0)) * freqmul;
		var detune = \dtune.kr(0);
		var width = \width.kr(0.5);
		var sig = VarSaw.ar([freq - detune, freq + detune], width:width);
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * env * AmpCompA.kr(freq) * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
		sig;
	}
});
Library.put(\voices, \pulse, {arg cb={arg sig; sig};

	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		var glide = \glide.kr(0) > 0;
		var gate = Trig1.kr(trig, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.3),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(1),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
		).kr(gate:gate);

		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0)) * freqmul;
		var detune = \dtune.kr(0);
		var width = \width.kr(0.5);
		var sig = Pulse.ar([freq - detune, freq + detune], width:width);
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * env * AmpCompA.kr(freq) * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
		sig;
	}
});
Library.put(\voices, \sine, {arg cb={arg sig; sig};
	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		var glide = \glide.kr(0) > 0;
		var gate = Trig1.kr(trig, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.3),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(1),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
		).kr(gate:gate);

		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0)) * freqmul;
		var detune = \dtune.kr(0);
		var sig = SinOsc.ar([freq - detune, freq + detune], \phase.ar([0,0]).mod(2pi));
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * env * AmpCompA.kr(freq) * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
		sig;
	}
});
Library.put(\voices, \saw, {arg cb={arg sig; sig};
	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		var glide = \glide.kr(0) > 0;
		var gate = Trig1.kr(trig, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.3),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(1),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
		).kr(gate:gate);

		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0)) * freqmul;
		var detune = \dtune.kr(0);
		var sig = Saw.ar([freq - detune, freq + detune]);
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * env * AmpCompA.kr(freq) * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
		sig;
	}
});
Library.put(\voices, \klang, {arg cb={arg sig; sig};
	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		var glide = \glide.kr(0) > 0;
		var gate = Trig1.kr(trig, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.3),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(1),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
		).kr(gate:gate);

		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0)) * freqmul;
		var detune = \dtune.kr(0);
		var sig = DynKlang.ar(
			`[
				[1, 2, 2.803, 3.871, 5.074, 7.81, 10.948, 14.421],   // freqs
				[1, 0.044, 0.891, 0.0891, 0.794, 0.1, 0.281, 0.079], // amplitudes
				[1, 0.205, 1, 0.196, 0.339, 0.047, 0.058, 0.047]     // ring times
			],
			[freq - detune, freq + detune]
		);
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * env * AmpCompA.kr(freq) * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
		sig;
	}
});
Library.put(\voices, \sinoscfb, {arg cb={arg sig; sig};
	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		var glide = \glide.kr(0) > 0;
		var gate = Trig1.kr(trig, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.3),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(1),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
		).kr(gate:gate);

		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0)) * freqmul;
		var detune = \dtune.kr(0);
		var sig = SinOscFB.ar([freq - detune, freq + detune], \feedback.kr(0));
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * env * AmpCompA.kr(freq) * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
		sig;
	}
});
Library.put(\voices, \klank, {arg cb={arg sig; sig};
	{
		var trig = \trig.tr;
		var which = \which.kr(0);
		var focus = \focus.kr(1);
		var noise = SelectXFocus.kr(which,
			[BrownNoise.ar(1), PinkNoise.ar(1), WhiteNoise.ar(1)],
			focus,
			wrap:true);

		var in = noise * Decay2.kr(trig, \atk.kr(0.01), \decay.kr(1));
		var numFreqs = 6;
		var detune = \dtune.kr(0);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432).varlag(\lag.kr(0.0))),
			\vrate.kr(6),
			\vdepth.kr(0.0),
			\vdelay.kr(0),
			\vonset.kr(0),
			\vrateVar.kr(0.04),
			\vdepthVar.kr(0.1)
		);

		var ffreqs = (0..numFreqs-1).collect({arg i;
			(\f ++ i).asSymbol.kr(1);
		}) + detune;

		var amps = (0..numFreqs-1).collect({arg i;
			(\a ++ i).asSymbol.kr(1/numFreqs);
		});

		var rings = (0..numFreqs-1).collect({arg i;
			(\r ++ i).asSymbol.kr(1);
		});

		var sig = DynKlank.ar(`[ffreqs, amps, rings], in, [freq - detune, freq + detune]);
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * AmpCompA.kr(freq) * \amp.kr(-12.dbamp);
		Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
	}
});
Library.put(\voices, \res, {arg cb={arg sig; sig};
	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		var glide = \glide.kr(0) > 0;
		var gate = Trig1.kr(trig, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.3),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(1),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
		).kr(gate:gate);

		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0)) * freqmul;
		var detune = \dtune.kr(0);
		var res = \res.kr(0.1);
		var sig = LeakDC.ar(RLPF.ar(PinkNoise.ar(0.3), [freq - detune, freq + detune], res));
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * env * AmpCompA.kr(freq) * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
		sig;
	}
});
Library.put(\voices, \syncsaw, {arg cb={arg sig; sig};
	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		var glide = \glide.kr(0) > 0;
		var gate = Trig1.kr(trig, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.3),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(1),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
		).kr(gate:gate);

		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0)) * freqmul;
		var detune = \dtune.kr(0);
		var sig = SyncSaw.ar([freq - detune, freq + detune], freq * \sync.kr(1.5));
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * env * AmpCompA.kr(freq) * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
		sig;
	}
});
Library.put(\voices, \fm7, {arg cb={arg sig; sig};
	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		var glide = \glide.kr(0) > 0;
		var gate = Trig1.kr(trig, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.3),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(1),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
		).kr(gate:gate);

		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0)) * freqmul;

		var ctrls = Array.fill(6, {arg i;
			[freq * ('r' ++ i).asSymbol.kr(1), 0, ('c' ++ i).asSymbol.kr(0)]
		});

		var mods = Array.fill2D(6, 6, {arg r, c;
			var key = ('m' ++ '_' ++ r ++ '_' ++ c);
			key.asSymbol.kr(0);
		});

		var sig = FM7.ar(ctrls, mods) * (0..5).collect({arg i; ('chan' ++ i).asSymbol.kr(0)});
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * AmpCompA.kr(freq) * env * \amp.kr(-6.dbamp);
		sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
		sig;
	}
});
Library.put(\voices, \noise, {arg cb={arg sig; sig};
	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		var glide = \glide.kr(0) > 0;
		var gate = Trig1.kr(trig, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.3),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(1),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
		).kr(gate:gate);

		var noises = [
			WhiteNoise.ar,
			PinkNoise.ar,
			BrownNoise.ar,
			GrayNoise.ar
		];

		var sig = SelectXFocus.ar(\which.kr(0), noises, \focus.kr(1));
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * env * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
		sig;
	}
});
Library.put(\voices, \pluck, {arg cb={arg sig; sig};
	{
		var which = \which.kr(1);
		var focus = \focus.kr(1);
		var noise = SelectXFocus.kr(
			which,
			[BrownNoise.ar(1), PinkNoise.ar(1), WhiteNoise.ar(1)],
			focus,
			wrap:true
		);

		var trig = \trig.tr;
		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432).lag(\lag.kr(0))), \vrate.kr(6), \vdepth.kr(0.001)) * freqmul;
		var detune = \dtune.kr(0);
		var temp = [freq + detune, freq - detune];
		var sig = Pluck.ar(RLPF.ar(noise, \nfreq.kr(18000), \nres.kr(0).linlin(0, 1, 1, 0.00001)),
			trig:trig,
			maxdelaytime:100.reciprocal,
			delaytime:temp.reciprocal,
			decaytime:\decay.kr(1),
			coef:\coef.kr(0.5)
		);
		sig = cb.(sig);
		sig = LeakDC.ar(sig) * AmpCompA.kr(freq) * \amp.kr(-6.dbamp);
		Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
	}
});

Library.put(\voices, \fm, {arg cb={arg sig; sig};
	{
		var trig = \trig.tr;
		var sus = \sus.kr(1);
		var glide = \glide.kr(0) > 0;
		var gate = Trig1.kr(trig, sus) * (1-glide) + glide;
		var env = Env.adsr(
			attackTime:\atk.kr(0.01),
			decayTime:\dec.kr(0.3),
			sustainLevel:\suslevel.kr(0.5),
			releaseTime:\rel.kr(1),
			curve:[\curve1.kr(-4), \curve2.kr(-4), \curve3.kr(-4)]
		).kr(gate:gate);

		var index = \index.kr(1);
		var ivel = \ivel.kr(1);
		var isuslevel = \isuslevel.kr(0.5);
		var ienv = Env(
			[1, ivel, ivel * isuslevel, ivel * isuslevel, 1],
			[\iatk.kr(0.01), \idec.kr(0.3), \isus.kr(1), \irel.kr(1)],
			[\icurve1.kr(-4), \icurve2.kr(-4), \icurve3.kr(-4)]
		).kr(gate:trig) * index;

		var freqmul = \freqmul.kr(1);
		var freq = Vibrato.ar(K2A.ar(\freq.kr(432)).lag(\lag.kr(0.0)), \vrate.kr(6), \vdepth.kr(0.0)) * freqmul;
		var detune = \dtune.kr(0);

		//modulator/carrier
		var mratio = \mratio.kr(1);
		var mod = SinOscFB.ar(freq * mratio, \feedback.kr(0)) * freq * mratio * ienv;
		var sig = SinOsc.ar([freq - detune, freq + detune] + mod);

		sig = cb.(sig);
		sig = LeakDC.ar(sig) * env * AmpCompA.kr(freq) * \amp.kr(-3.dbamp);
		sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
		sig;
	}
});
)