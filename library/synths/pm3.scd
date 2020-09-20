(
SynthDef(\pm3, {

	var numops = 3;
	var fb = LocalIn.ar(numops);
	var gate = \gate.kr(1);
	var freq = \freq.kr(220);
	var detune = \detuneratio.kr(1.01);

	var freqs = numops.collect({|i|
		var num = i+1;
		var ratio = ('op' ++ num ++ 'ratio').asSymbol.kr(1);
		freq * ratio;// * (detune ** Rand(-1, 1));
	});

	var mods = numops.collect({|i|
		var y = i + 1;
		numops.collect({|j|
			var x = j + 1;
			var key = ('m' ++ y ++ '_' ++ x).asSymbol;
			key.kr(0);
		});
	});

	var amps = numops.collect({|i|
		var num = i + 1;
		var amp = ('op' ++ num).asSymbol.kr(1);
		amp;
	});

	var meg = Env.perc(0.01, \mrel.kr(0.1), curve:\mcurve.kr(-4)).ar(gate:gate);

	var sig = numops.collect({|i|
		var mod = fb * mods[i] * meg;
		SinOsc.ar(freqs[i], mod.mod(2pi)).sum;
	});

	var aeg = Env.asr(
		\atk.kr(0.01), 1,
		\rel.kr(0.1),
		curve:\curve.kr(-4)
	).ar(doneAction:Done.freeSelf, gate:gate);

	var cutoff = \cutoff.kr(1480);
	var fvel = \fvel.kr(10);
	var feg = aeg.linlin(0, 1, cutoff, cutoff * fvel);

	sig = LeakDC.ar(sig);
	LocalOut.ar(sig);

	sig = LPF.ar(sig, feg, \res.kr(0.8).linlin(0, 1, 1, 0.001));
	sig = sig * amps.normalizeSum.max(0) * AmpCompA.kr(freqs);
	sig = sig.sum * aeg;
	sig = sig * \amp.kr(-3.dbamp) * \vel.kr(1);
	Out.ar(\out.kr(0), sig!2);

}, metadata: (
	specs: (
		detuneratio: ControlSpec([1, 2, \lin, 0, 1.01])
	)
)).add;
)