// idea stolen from sonic-pi
(
SynthDef(\hollow, {

	var freq = Vibrato.kr(\freq.kr(432), 6, 0.01);
	var res = \res.kr(0.01);
	var cutoff = \cutoff.kr(1479);
	var env = Env.linen(
		\atk.kr(0.01),
		\sus.kr(0),
		\rel.kr(1),
		curve:\cub
	).kr(doneAction:Done.freeSelf);

	var noise = WhiteNoise.ar(0.2);
	var sig1 = BPF.ar(noise * env, freq, res);
	var sig2 = BPF.ar(noise * env, freq * 2, res) * 0.5;
	var sig3 = BPF.ar(noise * env, freq * 4, res) * 0.125;
	var sig = LPF.ar(sig1 + sig2 + sig3, cutoff);

	sig = sig * AmpCompA.kr(freq) * \amp.kr(-20.dbamp) * 200;

	sig = Pan2.ar(sig, \pan.kr(0));

	Out.ar(\out.kr(0), sig);

}).add;
)

/////////////////////////////////////////
// plot env
Env.linen(6,1,6,curve:\cub).plot;
Env.perc(curve:\cub).plot

Pdef(\hollow).clear;
(
Pdef(\hollow, Ppar([
	Pbind(\instrument, \hollow,
		\freq, Prand(['G#3', 'C#3'].namecps, inf),
		\beatDur, Pfunc({thisThread.clock.beatDur}),
		\atk, 6 * Pkey(\beatDur),
		\rel, 6 * Pkey(\beatDur),
		\dur, 12,
		\amp, 0.dbamp
	),
	Pbind(\instrument, \hollow,
		\freq, Prand(['F#3', 'B3'].namecps, inf),
		\beatDur, Pfunc({thisThread.clock.beatDur}),
		\atk, 4 * Pkey(\beatDur),
		\rel, 5 * Pkey(\beatDur),
		\dur, 10,
		\amp, 0.dbamp
	),
	Pbind(\instrument, \hollow,
		\freq, Prand(['A3', 'D#3'].namecps, inf),
		\beatDur, Pfunc({thisThread.clock.beatDur}),
		\atk, 5 * Pkey(\beatDur),
		\rel, 5 * Pkey(\beatDur),
		\dur, 11,
		\amp, 0.dbamp
	)
]))
)

/////////////////////////////////////////
// hollow
~p[\hollow].clear;
~p[\hollow].mold;
~p[\hollow][0] = Pdef(\hollow);
(~p[\hollow].filter(2, {arg in;
	JPverb.ar(in, 5, 0, SinOsc.kr(1/24).range(1.0,2.0));
}).set(\wet2, 0.3)
)

~p[\hollow].play(fadeTime:10, vol:-6.dbamp);
~p[\hollow].stop(fadeTime:10);
~hollow_win = App.guiHelper(~p[\hollow], "hollow");
~hollow_win.front;

App.saveWorkspace("ws2");
TempoClock.default.tempo_(45/60);

  