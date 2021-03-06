{|inKey, inFunc|

	SynthDef(inKey, {

		var gate = \gate.kr(1);
		var in_freq = \freq.ar(261).lag(\glis.kr(0));
		var detune = \detunehz.kr(0.6) * PinkNoise.ar(0.007).range(0.9, 1.1);

		// bend by semitones...
		var bend = \bend.ar(0).midiratio;
		var freqbend = in_freq * bend;
		var freq = Vibrato.ar([freqbend + detune.neg, freqbend + detune], \vrate.ar(6), \vdepth.ar(0.0));

		var adsr = {
			var atk = \atk.kr(0.01);
			var dec = \dec.kr(0.1);
			var rel = \rel.kr(0.1);
			var suslevel = \suslevel.kr(1);
			var ts = \ts.kr(1);
			var curve = \curve.kr(-4);
			var env = Env.adsr(
				attackTime:atk,
				decayTime:dec,
				sustainLevel:suslevel,
				releaseTime:rel,
				curve:curve
			);
			var aeg = env.ar(doneAction:Done.freeSelf, gate:gate, timeScale:ts);
			aeg;
		};

		var aeg = adsr.();
		var sig = SynthDef.wrap(inFunc, prependArgs:[freq, gate, aeg]);
		sig = LeakDC.ar(sig);
		sig = sig * aeg * AmpCompA.ar(freq, 0) * \vel.kr(1);
		sig = Splay.ar(sig, \spread.kr(1), center:\pan.kr(0));
		sig = sig * \amp.kr(-6.dbamp);
		Out.ar(\out.kr(0), sig);

	}).add;
}