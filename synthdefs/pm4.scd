/////////////////////////////////////////
// pm4
(
SynthDef(\pm4, {

	var numops = 4;
	var fb = LocalIn.ar(numops);

	var trig = Trig1.kr(\trig.tr(1), \sustain.kr(1));
	var gate = Select.kr(\retrig.kr(0), [\gate.kr(1), trig]);
	var in_freq = \freq.ar(261).lag(\glis.kr(0));
	var bend = \bend.ar(0).midiratio;
	var freqbend = in_freq * bend;
	var freq = Vibrato.ar(freqbend, \vrate.kr(6), \vdepth.kr(0.001));
	var detunehz = \detunehz.kr(3);
	var vel = \vel.kr(1);

	var aeg = Env.asr(
		\atk.kr(0.01),
		\suslevel.kr(1),
		\rel.kr(1),
		curve:\curve.kr(-4)
	).kr(gate:gate) * WhiteNoise.ar(0.007).range(0.5, 1.0);

	var car = numops.collect({arg i;
		var num = i+1;
		var ratio = ('op' ++ num ++ 'ratio').asSymbol;
		var ccurve = ('op' ++ num ++ 'curve').asSymbol.kr(0);
		var cvel = ('op' ++ num ++ 'cslope').asSymbol.kr(1);
		var env = aeg.pow(cvel).lincurve(0, 1, 0, 1, ccurve);
		[freq * ratio.kr(1) + Rand(detunehz.neg, detunehz), env]
	});

	var mods = numops.collect({arg i;
		var y = i + 1;
		numops.collect({arg j;
			var x = j + 1;
			var key = ('m' ++ y ++ '_' ++ x).asSymbol;
			key.kr(0);
		});
	});

	var sig = numops.collect({arg i;
		var freq = car[i][0].clip(20, 20000);
		var index = mods[i];
		var mod = (fb * index).sum; // also sounds good not summed here
		var sig = SinOsc.ar(freq, mod.mod(2pi)) * car[i][1];
		sig;//.sum;
	});

	sig = LeakDC.ar(sig);

	LocalOut.ar(sig);

	// set output level
	sig = sig * numops.collect({arg i;
		var num = i + 1;
		var key = ('op' ++ num).asSymbol;
		key.kr(1.reciprocal);
	}).normalizeSum;

	// set panning
	sig = numops.collect({arg i;
		var num = i + 1;
		var key = ('op' ++ num ++ 'pan').asSymbol;
		Pan2.ar(sig[i],	key.kr(0),	1)
	}).sum;

	sig = BLowPass.ar(
		BHiPass.ar(sig,
			\hpf.kr(20).clip(20, 18000),
			\hpfres.kr(0).linlin(0, 1, 1, 0.001)
		),
		\lpf.kr(20000).clip(20, 20000),
		\lpfres.kr(0).linlin(0, 1, 1, 0.001)
	);

	sig = sig * AmpCompA.kr(freq) * \amp.kr(0.1) * vel;
	DetectSilence.ar(sig, doneAction:Done.freeSelf);
	Out.ar(\out.kr(0), sig);

}).add;
)