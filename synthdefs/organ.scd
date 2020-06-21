(
/*
// down an octave
f1 = 1;
f1ratio = -12.midiratio;

// 5th
f2 = 1/2;
f2ratio = 7.midiratio;

// fundamental
f3 = 1/3;
f3ratio = 1;

// octave
f4 = 1/4;
f4ratio = 12.midiratio;

// octave + 5th
f5 = 1/5;
f5ratio = 19.midiratio;

// two octaves
f6 = 1/6;
f6ratio = 24.midiratio;

// two octaves + major 3rd
f7 = 1/7;
f7ratio = 27.midiratio;

// two octaves + 5th
f8 = 1/8;
f8ratio = 31.midiratio;

// three octaves
f9 = 1/9;
f9ratio = 36.midiratio;
*/

SynthDef(\organ, {

	var num = 9;
	// support mono or poly mode
	var trig = Trig1.kr(\trig.tr(1), \sustain.kr(1));
	var gate = Select.kr(\retrig.kr(0), [\gate.kr(1), trig]);
	var in_freq = \freq.ar(261).lag(\glis.kr(0));
	var detune = \detunehz.kr(0.6) * PinkNoise.ar(0.007).range(0.9, 1.1);

	// bend by semitones...
	var bend = \bend.ar(0).midiratio;
	var freqbend = in_freq * bend;
	var freq = Vibrato.ar([freqbend + detune.neg, freqbend + detune], \vrate.ar(6), \vdepth.ar(0.0));

	var sig = DynKlang.ar(`[
		freq * num.collect({arg i;
			var n = i + 1;
			('f' ++ n ++ 'ratio').asSymbol.kr(n)
		}),
		num.collect({arg i;
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
		Env.adsr(atk, dec, sus,  rel, curve)
		.ar(gate:gate, doneAction:Done.freeSelf);
	};

	var filter = {arg in;
		var cutoff = \cutoff.kr(220);
		var fvel = \fvel.kr(10);
		var res = \res.kr(0.1);
		var feg = Env.adsr(
			\fatk.kr(0.01),
			\fdec.kr(0.3),
			\fsuslevel.kr(1),
			\frel.kr(1),
			curve:\fcurve.kr(-4)
		).ar(gate:gate).linexp(0, 1, cutoff, cutoff * fvel).clip(20, 20000);
		var sig = MoogVCF.ar(in, feg, res);
		sig;
	};

	var aeg = adsr.();

	var filtsig;

	var drive = \drive.kr(1).max(1);
	sig = Select.ar( (drive > 1), [sig, LeakDC.ar((sig * drive).softclip)]);
	sig = sig * aeg * \amp.kr(0.3) * \vel.kr(1);
	filtsig = filter.(sig);
	sig = sig.blend(filtsig, \famt.kr(0));
	sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
	Out.ar(\out.kr(0), sig);

}).add;
)