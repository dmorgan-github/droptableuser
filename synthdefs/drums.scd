(
SynthDef(\kick, {

	var env0, env1, env1m, sig;

	env0 =  EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.06, 0.26], [-4, -2, -4]), doneAction:2);
	env1 = EnvGen.ar(Env.new([110, 59, 29], [0.005, 0.29], [-4, -5]));
	env1m = env1.midicps;

	sig = LFPulse.ar(env1m, 0, 0.5, 1, -0.5);
	sig = sig + WhiteNoise.ar(1);
	sig = LPF.ar(sig, env1m*1.5, env0);
	sig = sig + SinOsc.ar(env1m, 0.5, env0);

	sig = sig * 1.2;
	sig = sig.clip2(1) * \amp.kr(1);

	Out.ar(\out.kr(0), sig.dup);
}).add;

SynthDef(\snare, {

	var env0, env1, env2, env1m, oscs, noise, sig;

	env0 = EnvGen.ar(Env.new([0.5, 1, 0.5, 0], [0.005, 0.03, 0.10], [-4, -2, -4]));
	env1 = EnvGen.ar(Env.new([110, 60, 49], [0.005, 0.1], [-4, -5]));
	env1m = env1.midicps;
	env2 = EnvGen.ar(Env.new([1, 0.4, 0], [0.05, 0.13], [-2, -2]), doneAction:2);

	oscs = LFPulse.ar(env1m, 0, 0.5, 1, -0.5) + LFPulse.ar(env1m * 1.6, 0, 0.5, 0.5, -0.25);
	oscs = LPF.ar(oscs, env1m*1.2, env0);
	oscs = oscs + SinOsc.ar(env1m, 0.8, env0);

	noise = WhiteNoise.ar(0.2);
	noise = HPF.ar(noise, 200, 2);
	noise = BPF.ar(noise, 6900, 0.6, 3) + noise;
	noise = noise * env2;

	sig = oscs + noise;
	sig = sig.clip2(1) * \amp.kr(0.8);

	Out.ar(\out.kr(0), sig.dup);
}).add;

SynthDef(\clap, {

	var env1, env2, sig, noise1, noise2;

	env1 = EnvGen.ar(Env.new([0, 1, 0, 1, 0, 1, 0, 1, 0], [0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03], [0, -3, 0, -3, 0, -3, 0, -4]));
	env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.3], [0, -4]), doneAction:2);

	noise1 = WhiteNoise.ar(env1);
	noise1 = HPF.ar(noise1, 600);
	noise1 = BPF.ar(noise1, 2000, 3);

	noise2 = WhiteNoise.ar(env2);
	noise2 = HPF.ar(noise2, 1000);
	noise2 = BPF.ar(noise2, 1200, 0.7, 0.7);

	sig = noise1 + noise2;
	sig = sig * 2;
	sig = sig.softclip * \amp.kr(0.5);

	Out.ar(\out.kr(0), sig.dup);
}).add;

SynthDef(\hat, {

	var env1, env2, sig, oscs1, noise, n, n2;

	n = 5;
	thisThread.randSeed = 4;

	env1 = EnvGen.ar(Env.new([0, 1.0, 0], [0.001, 0.2], [0, -12]));
	env2 = EnvGen.ar(Env.new([0, 1.0, 0.05, 0], [0.002, 0.05, 0.03], [0, -4, -4]), doneAction:2);

	oscs1 = Mix.fill(n, {|i|
		SinOsc.ar(
			( i.linlin(0, n-1, 42, 74) + rand2(4.0) ).midicps,
			SinOsc.ar( (i.linlin(0, n-1, 78, 80) + rand2(4.0) ).midicps, 0.0, 12),
			1/n
		)
	});

	oscs1 = BHiPass.ar(oscs1, 1000, 2, env1);
	n2 = 8;
	noise = WhiteNoise.ar;
	noise = Mix.fill(n2, {|i|
		var freq;
		freq = (i.linlin(0, n-1, 40, 50) + rand2(4.0) ).midicps.reciprocal;
		CombN.ar(noise, 0.04, freq, 0.1)
	}) * (1/n) + noise;
	noise = BPF.ar(noise, 6000, 0.9, 0.5, noise);
	noise = BLowShelf.ar(noise, 3000, 0.5, -6);
	noise = BHiPass.ar(noise, 1000, 1.5, env2);

	sig = noise + oscs1;
	sig = sig.softclip;
	sig = sig * \amp.kr(0.3);

	Out.ar(\out.kr(0), sig.dup);
}).add;
)