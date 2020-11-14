{|inKey, inFunc|

	SynthDef(inKey, {
		var freq = \freq.ar(261);
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
		var sig = inFunc.(freq, 1, aeg);

		sig = LeakDC.ar(sig);
		sig = sig * aeg * AmpCompA.ar(freq, 32) * \vel.kr(1);
		sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
		sig = sig * \amp.kr(-6.dbamp);
		Out.ar(\out.kr(0), sig);

	}).add;
}