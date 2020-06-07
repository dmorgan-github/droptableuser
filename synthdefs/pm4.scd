/////////////////////////////////////////
// pm4
(
SynthDef(\pm4, {

	var numops = 4;
	var fb = LocalIn.ar(numops);

	// note: this won't work in mono mode
	var gate = \gate.kr(1);
	var in_freq = \freq.ar(261).lag(\glis.kr(0));
	var bend = \bend.ar(0).midiratio;
	var freqbend = in_freq * bend;
	var freq = Vibrato.ar(freqbend, \vrate.kr(6), \vdepth.kr(0.0));
	var detunehz = \detunehz.kr(0);
	var vel = \vel.kr(1);

	var car = numops.collect({arg i;
		var num = i+1;
		var ratio = ('op' ++ num ++ 'ratio').asSymbol;
		var curve = ('op' ++ num ++ 'curve').asSymbol.kr(0);
		var atk = ('op' ++ num ++ 'atk').asSymbol.kr(0.01);
		var dec = ('op' ++ num ++ 'dec').asSymbol.kr(0.01);
		var suslevel = ('op' ++ num ++ 'suslevel').asSymbol.kr(1);
		var rel = ('op' ++ num ++ 'rel').asSymbol.kr(1);
		var env = Env.adsr(
			attackTime:atk,
			decayTime:dec,
			sustainLevel:suslevel,
			releaseTime:rel,
			curve:curve
		).kr(gate:gate);
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
		var num = i+1;
		var freq = car[i][0].clip(20, 20000);
		var index = mods[i];
		var mod = (fb * index).sum; // also sounds good not summed here
		var sig = SinOsc.ar(freq, mod.mod(2pi)) * car[i][1];
		var coef = ('op' ++ num ++ 'coef').asSymbol.kr(0.5).clip(0, 1);
		//sig = OnePole.ar(sig, coef);
		var lpf = coef.linlin(0, 1, 20, 20000);
		sig = LPF.ar(sig, lpf);
		sig;
	});

	sig = LeakDC.ar(sig);

	LocalOut.ar(sig);

	// set output level
	sig = sig * numops.collect({arg i;
		var num = i + 1;
		var key = ('op' ++ num).asSymbol;
		key.kr(1);
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
	sig = sig.softclip;

	Out.ar(\out.kr(0), sig);

}).add;
)
