p = ProxySpace.push(s);
p.makeTempoClock(45/60);

~s1.play;
~s1.quant = 1.0;
~s1.fadeTime = 5;
(~s1 = {

	var t_trig = Impulse.kr(~tempo.kr);

	var lag = \lag.kr(0.0);
	var freq = \freq.kr(110).lag(lag);

	var num = 1e-6;

	var env = EnvGen.kr(Env([0, 0, 1, 0.7, 0], [num, 0.01, 1, 1 ], -4), gate: t_trig, timeScale: 0.5);

	var fblevel1 = 2.5;
	var fbenv = EnvGen.kr(Env([fblevel1, fblevel1, 0.1], [num, 1], 4), gate: t_trig, timeScale: 1);

	var ilevel1 = \ilevel1.kr(6);
	var ienv = EnvGen.kr(Env([ilevel1, ilevel1, 3], [num, 1], 4), gate: t_trig, timeScale: 0.1);
	var sig = SinOscFB.ar(freq * [1, 1.01], fbenv) + PMOsc.ar(freq * [1, 1.01], freq * [2.55, 0.507], ienv, mul:0.5) + Gendy1.ar(mul:0.2);

	var fenv = EnvGen.kr(Env([990, 2990, 90, 65], [num, 1, 1], -4), gate: t_trig, timeScale: 1);
	var qenv = EnvGen.kr(Env([0.1, 0.1, 0.2, 0.7], [num, 1, 1], -4), gate: t_trig);

	sig = RLPF.ar(sig, fenv, qenv);

	sig * env * 0.2;

});

(~s1[5] = \filter -> {arg in;

	var fbNode = FbNode(2, 1);
	var fb = fbNode.delay(0.375 / ~tempo.kr).tanh * 0.6;
	var fb2 = fbNode.delay(0.675 / ~tempo.kr).reverse.tanh * 0.8;
	var fb3 = fbNode.delay(0.5 / ~tempo.kr).abs * 0.8;

	fbNode.write(in + fb);
	(in * 0.3) + fb + WaveLoss.ar(fb3);// + (FreqShift.ar(fb2, 200) * 0.8) + ( WaveLoss.ar(fb3) * 0.8);
});

~s1.set(\wet5, 0.7)
~s1.set(\ilevel1, 6);

~s1.stop(5);
~s2.stop(5);

~s2.vol = 0.5
