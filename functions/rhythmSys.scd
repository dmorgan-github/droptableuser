(
SynthDef(\click1, {arg amp = 1, pan = 0, out = 0, rezfreq = 10000;

	var env = XLine.kr(amp, 0.001, 0.0025, doneAction: 2);
	var sig = Resonz.ar(WhiteNoise.ar(0.5), rezfreq);
	sig = BPF.ar(sig, 15000, 0.9).fold(-1, 1);
	OffsetOut.ar(out, Pan2.ar(sig * env, pan));
}).add;

SynthDef(\clap, {arg outBus=0, amp = 0.3;

	var env1, env2, out, noise1, noise2;

	env1 = EnvGen.ar(Env.new([0, 1, 0, 1, 0, 1, 0, 1, 0], [0.001, 0.013, 0, 0.01, 0, 0.01, 0, 0.03], [0, -3, 0, -3, 0, -3, 0, -4]));
	env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.3], [0, -4]), doneAction:2);

	noise1 = WhiteNoise.ar(env1);
	noise1 = HPF.ar(noise1, 600);
	noise1 = BPF.ar(noise1, 2000, 3);

	noise2 = WhiteNoise.ar(env2);
	noise2 = HPF.ar(noise2, 1000);
	noise2 = BPF.ar(noise2, 1200, 0.7, 0.7);

	out = noise1 + noise2;
	out = out * 2;
	out = out.softclip * amp;

	Out.ar(outBus, out.dup);
}).add;

SynthDef(\hat, {arg outBus=0, amp=0.3;
	var env1, env2, out, oscs1, noise, n, n2;

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

	out = noise + oscs1;
	out = out.softclip;
	out = out * amp;

	Out.ar(outBus, out.dup);
}).add;

SynthDef(\kick1, {arg out = 0, pan = 0, amp=1;

	var env1 = Env([110, 59, 29], [0.05, 0.29], [-4, -5]);
    var envgen = EnvGen.ar(env1);

	var env = EnvGen.kr(Env.perc(0,1, amp), doneAction:2);
	var sig = LPF.ar( Ringz.ar( Impulse.ar(0), 60, 0.5 ), 500 ) + SinOsc.ar(envgen, 0.5pi);
	var cmp = CompanderD.ar(sig, thresh: -20.dbamp, slopeBelow: 1, slopeAbove: 0.3, clampTime: 0.003, relaxTime: 0.08);
    sig = (cmp * (10.dbamp * 0.25)) ! 2;
	OffsetOut.ar(out, Pan2.ar(sig * env, pan));
}).add;

SynthDef(\hat2, {arg out=0, amp=0.5;
	var sig = WhiteNoise.ar;
	var env = EnvGen.kr(Env.perc(0, 0.01, amp), doneAction: 2);
	Out.ar(out, Pan2.ar(sig, 0, env));
}).add;

SynthDef(\hat3, {arg out = 0, rezfreq = 10000, pan = 0;

	var env = XLine.kr(1, 0.001, 0.0025, doneAction: 2);
	var sig = Resonz.ar(WhiteNoise.ar(0.5), rezfreq);
	sig = BPF.ar(sig, 15000, 0.9).fold(-1, 1);
	OffsetOut.ar(out, Pan2.ar(sig * env, pan));

}).add;

~rhythmSys = (

	proto: ~instrument,

	kik1_new: {arg self, pattern;

		var ptrn = (
			instrument: \kick2,
			dur: Prand( (0.5!8) ++ (0.25!8) ++ [Pseq([0.125, 0.125], 1)] , inf),
			amp:1
		);

		if (pattern.isNil.not) {
			pattern.keysValuesDo({arg key, value;
				ptrn.put(key, value);
			});
		};

		self.inst_new(ptrn, inf);
	},

	click1_new: {arg self, pattern;
		var ptrn = (
			instrument: \click1,
			dur: Pxrand( (0.25!8) ++ (0.125!8) ++ [Pseq([0.0625, 0.0625], 2)] , inf),
			amp: Prand([0.6, 0.9], inf),
			pan: Pwhite(-1, 1, inf)
		);

		if (pattern.isNil.not) {
			pattern.keysValuesDo({arg key, value;
				ptrn.put(key, value);
			});
		};
		self.inst_new(ptrn, inf);
	},

	clap1_new: {arg self, pattern;
		var ptrn = (
			instrument: \clap,
			dur: Pseq([Rest(1), 1], inf),
			amp: 0.3
		);
		if (pattern.isNil.not) {
			pattern.keysValuesDo({arg key, value;
				ptrn.put(key, value);
			});
		};
		self.inst_new(ptrn, inf);
	},

	hh1_new: {arg self, pattern;
		var ptrn = (
			instrument: \hat,
			dur: 0.5,
			amp: 0.1
		);
		if (pattern.isNil.not) {
			pattern.keysValuesDo({arg key, value;
				ptrn.put(key, value);
			});
		};
		self.inst_new(ptrn, inf);
	}
);
);