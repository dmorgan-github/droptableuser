{|inKey, inFunc|

	SynthDef(inKey, {

		var freq_in = \freq.ar(261);
		var detune = \detunehz.kr(0.6) * PinkNoise.ar(0.007).range(0.9, 1.1);
		var bend = \bend.ar(0).midiratio;
		var freqbend = freq_in * bend;
		var freq = Vibrato.ar([freqbend + detune.neg, freqbend + detune], \vrate.ar(6), \vdepth.ar(0.0));

		var ar = {
			var atk = \atk.kr(0.01);
			var rel = \rel.kr(0.1);
			var ts = \ts.kr(1);
			var curve = \curve.kr(-4);
			var env = Env.perc(
				attackTime:atk,
				releaseTime:rel,
				curve:curve
			);
			var aeg = env.ar(doneAction:Done.freeSelf, timeScale:ts);
			aeg;
		};

		var aeg = ar.();
		var sig = SynthDef.wrap(inFunc, prependArgs:[freq, 1, aeg]);//inFunc.(freq, 1, aeg);

		sig = LeakDC.ar(sig);
		sig = sig * aeg * AmpCompA.ar(freq, 32) * \vel.kr(1);
		sig = Splay.ar(sig, \spread.kr(1), center:\pan.kr(0));
		sig = sig * \amp.kr(-6.dbamp);
		Out.ar(\out.kr(0), sig);

	}).add;
}