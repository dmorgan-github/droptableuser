{|inKey, inFunc, specs|

    var metadata = ('env': 'adsr');
    if (specs.notNil;) {
        metadata['specs'] = specs.asDict
    };

    SynthDef(inKey, {

		var trig = \trig.tr(1);
		var in_freq = \freq.ar(261).lag(\glis.kr(0));
		var detune = \detunehz.kr(0.6) * PinkNoise.ar(0.007).range(0.9, 1.1);

		// bend by semitones...
		var bend = \bend.ar(0).midiratio;
		var freqbend = in_freq * bend;
		var freq = Vibrato.ar([freqbend + detune.neg, freqbend + detune], \vrate.ar(6), \vdepth.ar(0.0));

		var adsr = {
			var atk = \atk.kr(0.01);
			var dec = \dec.kr(0.1);
			var rel = \rel.kr(1);
			var suslevel = \suslevel.kr(1);
			var sus = \sustain.kr(1);
			var curve = \curve.kr(-4);
			var aeg = Env(
				[0, 1, suslevel, suslevel, 0],
				[atk, dec, sus, rel],
				curve:curve
			).ar(doneAction:Done.none, gate:trig);

			// control synth lifecycle
			Env.asr(atk, 1, rel, curve).kr(doneAction:Done.freeSelf, gate:\gate.kr(1));

			aeg;
		};

		var aeg = adsr.();
		var sig = SynthDef.wrap(inFunc, prependArgs:[freq, trig, aeg]);//inFunc.(freq, trig, aeg);
		sig = LeakDC.ar(sig);
		sig = sig * aeg * AmpCompA.ar(freq, 0) * \vel.kr(1);
		sig = Splay.ar(sig);
		sig = sig * \amp.kr(-6.dbamp);
		Out.ar(\out.kr(0), sig);

	},
    metadata: metadata
).add;
}
