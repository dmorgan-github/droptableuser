(
SynthDef("bass", { arg freq = 440, amp = 0.5, gate = 1;
	var snd, env, oscfreq, output;
	oscfreq = {freq * LFNoise2.kr(0.5).range(0.98, 1.02)}!3;
	//snd = Splay.ar(LFSaw.ar(oscfreq, mul: amp));
	snd = Splay.ar(Saw.ar(oscfreq, mul: amp));
	env = Env.adsr(0.7, 4, 0, 0.1).kr(doneAction:2, gate: gate);
	snd = snd;
	//output = LPF.ar(snd, (env*freq) + 2*freq);
	output = DFM1.ar(snd, (env*freq) + 2*freq);
	Out.ar(0, output);
	}).add;
)

p = Pbind(
	\instrument, "bass",
	\tempo, 113/60,
	\ctranspose, -26,
	\degree, Pseq([Pseq([3, 5, 1, 3, 5, 8, 1], 2), Pseq([3, 2, 5, -1], 1), Pseq([3, 2, 5, 0], 1), Pseq([1, 5, 0,1,2,5,4], 2), Pseq([1, 0,2],2), 3],inf),
	\dur, Pseq([Pseq([8, 4, 4, 8, 4, 2, 2], 2), Pseq([8,4,2, 2], 2),Pseq([8, 4, 4, 8, 4, 2, 2], 2), Pseq([8, 4, 4], 2), 16], inf),
	\legato, 1,
	\amp, 0.01,
).play;

p.stop
