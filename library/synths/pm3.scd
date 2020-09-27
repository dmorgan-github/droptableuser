(
var algos = [
	#[
		0, 0, 0,
		0, 0, 0,
		0, 0, 0
	],
	#[
		0, 1, 0,
		0, 1, 1,
		0, 0, 1
	],
	#[
		0, 1, 0,
		0, 0, 1,
		0, 0, 1
	],
	#[
		1, 0, 1,
		0, 0, 0,
		0, 0, 1
	],
	#[
		1, 1, 0,
		1, 0, 1,
		0, 0, 1
	]
];

SynthDef(\pm3, {

	var numops = 3;
	var fb = LocalIn.ar(numops);
	var gate = \gate.kr(1);
	var freq = Vibrato.ar(\freq.ar(220), \vrate.kr(6), \vdepth.kr(0.0));// * [1, 1.01];
	//var detune = \detuneratio.kr(1.01);

	var k = (1..numops);
	var b = \harm.kr(1);
	var ratios = k * (1 + ((k-1) * b));
	//var ratios = 2.pow( (1..numops) * b );

	var morph = \morph.kr(0);
	var algo = \algo.kr(0);
	var timbres = numops.collect({|i|
		var timbre = \timbre.kr.dup(numops);
		timbre[i] = morph;
		timbre;// * pi;
	})
	* Select.kr(algo, algos).clump(numops);

	var freqs = numops.collect({|i|
		var num = i+1;
		freq * ratios[i];
	});

	var amps = numops.collect({|i|
		var num = i + 1;
		var amp = ('op' ++ num).asSymbol.kr(1);
		amp;
	});

	var meg = Env.asr(
		\matk.kr(0.01),
		\msuslevel.kr(1),
		\mrel.kr(0.1),
		curve:\mcurve.kr(-4)
	).ar(gate:gate);

	var sig = numops.collect({|i|
		var mod = fb * timbres[i] * meg;
		SinOsc.ar(freqs[i], mod.mod(2pi)).sum;
	});

	var aeg = Env.asr(
		\atk.kr(0.01), 1,
		\rel.kr(0.1),
		curve:\curve.kr(-4)
	).ar(doneAction:Done.freeSelf, gate:gate);

	var cutoff = \cutoff.kr(0.5);//.linlin(0, 1, 20, 20000);
	var fvel = \fvel.kr(1);
	var res = \res.kr(0.1);
	var feg = aeg.linlin(0, 1, 1, fvel) * cutoff; // .linlin(0, 1, cutoff, cutoff * fvel).clip(20, 20000);
	feg = feg.clip(0.1, 1);//.linlin(0, 1, 20, 20000);

	sig = LeakDC.ar(sig);
	LocalOut.ar(sig);

	//sig = MiRipples.ar(sig, feg, res, \drive.kr(1));
	//sig = SVF.ar(sig, feg.linexp(0.1, 1, 20, 20000), res, 1);
	//sig = RLPF.ar(sig, feg.linexp(0.1, 1, 20, 20000), res.linlin(0, 1, 1, 0.0001));
	//sig = DFM1.ar(sig, feg.linexp(0.1, 1, 20, 20000), res, \drive.kr(1));
	//sig = BLowPass4.ar( softclip(sig * \fdrive.kr(1)), feg.linexp(0.1, 1, 20, 20000), res.linlin(0, 1, 1, 0.0001));
	sig = Select.ar( \drive.kr(1) > 1, [ sig, LeakDC.ar(tanh(sig * \fdrive.kr(1))) ]);
	sig = BLowPass4.ar(sig, feg.linexp(0.1, 1, 20, 20000), res.linlin(0, 1, 1, 0.0001));

	sig = sig * amps.normalizeSum.max(0) * AmpCompA.kr(freqs);
	//sig = sig + (SinOsc.ar(freq * 0.5));
	sig = sig.sum * aeg;
	sig = sig * \amp.kr(-3.dbamp) * \vel.kr(1);
	Out.ar(\out.kr(0), sig!2);

}, metadata: (
	specs: (
		harm: ControlSpec(-0.001, 2, \lin, 0, 1, "fm"),
		timbre: ControlSpec(0, 1, \lin, 0, 0, "fm"),
		morph: ControlSpec(0, 1, \lin, 0, 0, "fm"),
		algo: ControlSpec(0, 4, \lin, 1, 4, "fm"),
		matk: ControlSpec(0, 1, \lin, 0, 0.01, units:"mod"),
		mrel: ControlSpec(0, 8, \lin, 0, 0.29, units:"mod"),
		msuslevel: ControlSpec(0, 1, \lin, 0, 1, units:"mod"),
		mcurve: ControlSpec(-8, 8, \lin, 0, -4, units:"mod"),

		cutoff: ControlSpec(0.1, 1, \lin, 0, 0.5, units:"filter"),
		fdrive: ControlSpec(1, 10, \lin, 0, 1, units:"filter")
	)
)).add;
)