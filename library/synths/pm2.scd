(
var algos = [
	//0
	#[
		0, 0,
		0, 0
	],
	//1
	#[
		0, 1,
		0, 1
	],
	//2
	#[
		1, 1,
		1, 1
	],
	//3
	#[
		0, 1,
		1, 1
	],
	//4
	#[
		0, 1,
		1, 0
	],
	//5
	#[
		1, 1,
		1, 0
	],
];

SynthDef(\pm2, {

	var numops = 2;
	var fb = LocalIn.ar(numops);
	var gate = \gate.kr(1);
	var detune = \detunehz.kr(0.6) * PinkNoise.ar(0.007).range(0.9, 1.1);
	var in_freq = \freq.kr(220);
	var freq = Vibrato.ar([in_freq + detune.neg, in_freq + detune], \vrate.ar(6), \vdepth.ar(0.0));
	var k = (1..numops);
	var b = \harm.kr(1);

	var ratios = {
		var val = k * (1 + ((k-1) * b));
		val/val[0];
	}.();

	var morph = \morph.kr(0);
	var algo = \algo.kr(0);
	var timbres = numops.collect({|i|
		var timbre = \timbre.kr.dup(numops);
		timbre[i] = morph;
		timbre;// * pi;
	})
	* Select.kr(algo, algos).clump(numops);

	var freqs = numops.collect({|i|
		freq * ratios[i];
	});

	var amps = numops.collect({|i|
		var num = i + 1;
		var amp = ('op' ++ num).asSymbol.kr(1);
		amp;
	});

	var meg = Env.adsr(
		attackTime:\matk.kr(0.01),
		decayTime:\mdec.kr(0.2),
		sustainLevel:\msuslevel.kr(1),
		releaseTime:\mrel.kr(0.1),
		curve:\mcurve.kr(-4)
	).ar(gate:gate);

	var sig = numops.collect({|i|
		var mod = (fb * timbres[i]).sum;// * meg;
		SinOsc.ar(freqs[i], mod.mod(2pi));
	});

	var aeg = Env.adsr(
		attackTime:\atk.kr(0.01),
		decayTime:\dec.kr(0.2),
		sustainLevel:\suslevel.kr(1),
		releaseTime:\rel.kr(0.1),
		curve:\curve.kr(-4)
	).ar(doneAction:Done.freeSelf, gate:gate);

	var cutoff = \cutoff.kr(0.5);//.linlin(0, 1, 20, 20000);
	var fvel = \fvel.kr(1);
	var res = \res.kr(0.1);
	var feg = aeg.linlin(0, 1, 1, fvel) * cutoff;
	feg = feg.clip(0.1, 1);//.linlin(0, 1, 20, 20000);

	sig = LeakDC.ar(sig);
	LocalOut.ar(sig);

	sig = Select.ar( \fdrive.kr(1) > 1, [ sig, LeakDC.ar(tanh(sig * \fdrive.kr(1))) ]);
	sig = BLowPass4.ar(sig, feg.linexp(0.1, 1, 20, 20000), res.linlin(0, 1, 1, 0.0001));

	sig = sig * amps.normalizeSum.max(0) * AmpCompA.kr(freqs);
	sig = (sig.sum + SinOsc.ar(freq * 0.5)) * aeg;
	sig = sig * \amp.kr(-3.dbamp) * \vel.kr(1);
	sig = Splay.ar(sig, \spread.kr(1), center:\center.kr(0));
	Out.ar(\out.kr(0), sig);

}, metadata: (
	created:"09/30/2020",
	type:\fm,
	specs: (
		harm: ControlSpec(-0.75, 2, \lin, 0, 1, "fm"),
		timbre: ControlSpec(0, 1, \lin, 0, 0, "fm"),
		morph: ControlSpec(0, 1, \lin, 0, 0, "fm"),
		algo: ControlSpec(0, 4, \lin, 1, 4, "fm"),
		matk: ControlSpec(0, 1, \lin, 0, 0.01, units:"mod"),
		mdec: ControlSpec(0, 1, \lin, 0, 0.2, units:"mod"),
		mrel: ControlSpec(0, 8, \lin, 0, 0.29, units:"mod"),
		msuslevel: ControlSpec(0, 1, \lin, 0, 1, units:"mod"),
		mcurve: ControlSpec(-8, 8, \lin, 0, -4, units:"mod"),

		cutoff: ControlSpec(0.1, 1, \lin, 0, 0.5, units:"filter"),
		fdrive: ControlSpec(1, 10, \lin, 0, 1, units:"filter")
	)
)).add;
)