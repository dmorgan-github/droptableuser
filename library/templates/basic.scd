{|inKey, inFunc, specs|

    var metadata = ();
    if (specs.notNil;) {
        metadata['specs'] = specs.asDict
    };

    SynthDef(inKey, {

        var gate = \gate.kr(1);
		var in_freq = \freq.ar(261).lag(\glis.kr(0));
		var detune = \detunehz.kr(0) * PinkNoise.ar(0.007).range(0.9, 1.1);

		// bend by semitones...
		var bend = \bend.ar(0).midiratio;
		var freqbend = in_freq * bend;
		var freq = Vibrato.ar([freqbend + detune.neg, freqbend + detune], \vrate.ar(6), \vdepth.ar(0.0));

        var sig = SynthDef.wrap(inFunc, prependArgs:[freq, gate, nil]);

		sig = LeakDC.ar(sig);
        sig = sig * AmpCompA.ar(freq, 0) * \amp.kr(-10.dbamp) * \vel.kr(1);
		sig = Splay.ar(sig);
		Out.ar(\out.kr(0), sig);
	},
    metadata: metadata
).add;
}