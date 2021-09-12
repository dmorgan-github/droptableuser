(
var harms = [-12, 7, 0, 12, 19, 24, 27, 31, 36].midiratio;
var specs = ();
harms.do({arg harm, i;
	var num = i + 1;
	var key = ('f' ++ num).asSymbol;
	specs[(key ++ 'ratio').asSymbol] = ControlSpec(-24.midiratio, harm, \lin, -12.midiratio, units:key);
	specs[(key ++ 'atk').asSymbol] = ControlSpec(0, 1, \lin, 0, 0.01, units:key);
	specs[(key ++ 'suslevel').asSymbol] = ControlSpec(0, 1, \lin, 0, 1, units:key);
	specs[(key ++ 'rel').asSymbol] = ControlSpec(0, 8, \lin, 0, 0.29, units:key);
	specs[(key ++ 'curve').asSymbol] = ControlSpec(-8, 8, \lin, 0, -4, units:key);
});

SynthDef(\organ, {

	var trig = Trig1.kr(\trig.tr(1), \sustain.kr(1));
	var gate = Select.kr(\retrig.kr(0), [\gate.kr(1), trig]);
	var in_freq = \freq.ar(261).lag(\glis.kr(0));
	var detune = \detunehz.kr(0.6) * PinkNoise.ar(0.007).range(0.9, 1.1);

	// bend by semitones...
	var bend = \bend.ar(0).midiratio;
	var freqbend = in_freq * bend;
	var freq = Vibrato.ar([freqbend + detune.neg, freqbend + detune], \vrate.ar(6), \vdepth.ar(0.0));

	var sig = DynKlang.ar(`[
		freq * harms.collect({arg harm, i;
			var n = i + 1;
			('f' ++ n ++ 'ratio').asSymbol.kr(harm)
		}),
		harms.collect({arg harm, i;
			var n = i + 1;
			var key = ('f' ++ n);
			Env.asr(
				attackTime:(key ++ 'atk').asSymbol.kr(0.01),
				sustainLevel:(key ++ 'suslevel').asSymbol.kr(1),
				releaseTime:(key ++ 'rel').asSymbol.kr(1),
				curve: (key ++ 'curve').asSymbol.kr(-4)
			).kr(gate:gate) * key.asSymbol.kr(1/n)
		}),
		nil
	]);

	var adsr = {
		var atk = \atk.kr(0.01);
		var dec = \dec.kr(0);
		var sus = \suslevel.kr(1);
		var rel = \rel.kr(1);
		var curve = \curve.kr(-4);
		Env.adsr(atk, dec, sus,  rel, curve: curve)
		.ar(gate:gate, doneAction:Done.freeSelf);
	};

	var filter = {arg in;

		var cutoff = \cutoff.kr(220);
		var res = \res.kr(0.1);

		/*
		var fvel = \fvel.kr(10);
		var feg = Env.adsr(
			\fatk.kr(0.01),
			\fdec.kr(0.3),
			\fsuslevel.kr(1),
			\frel.kr(1),
			curve:\fcurve.kr(-4)
		).ar(gate:gate).linexp(0, 1, cutoff, cutoff * fvel).clip(20, 20000);
		*/
		//var sig = MoogVCF.ar(in, feg, res);
		var sig = BLowPass.ar(in, cutoff, res.linlin(0, 1, 1, 0.001));
		//var sig = DFM1.ar(in, cutoff, res, inputgain:\drive.kr(1));
		sig;
	};

	var aeg = adsr.();
	var drive = \drive.kr(1).max(1);
	sig = Select.ar( (drive > 1), [
		sig,
		LeakDC.ar((sig * drive).tanh) * drive.sqrt.reciprocal
	]);

	sig = filter.(sig);
	sig = sig * aeg * AmpCompA.kr(freq, 20) * \amp.kr(0.3) * \vel.kr(1);
	sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
	Out.ar(\out.kr(0), sig);

}, metadata: (
	specs: specs
)
).add;
)
