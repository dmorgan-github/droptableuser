// idea stolen from sonic-pi
(
SynthDef(\hollow, {

	var freq =  \freq.kr('E2'.namecps);
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

	sig = sig * AmpCompA.kr(freq) * \amp.kr(-20.dbamp) * 15;

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
		//\foo, Pfunc({arg evt; evt[\freq].cpsname.debug("foo")}),
		\atk, 6,
		\rel, 6,
		\dur, 12,
		\amp, 0.dbamp
	),
	Pbind(\instrument, \hollow,
		\freq, Prand(['F#3', 'B3'].namecps, inf),
		//\foo, Pfunc({arg evt; evt[\freq].cpsname.debug("foo2")}),
		\atk, 4,
		\rel, 5,
		\dur, 10,
		\amp, 0.dbamp
	),
	Pbind(\instrument, \hollow,
		\freq, Prand(['A3', 'D#3'].namecps, inf),
		//\foo, Pfunc({arg evt; evt[\freq].cpsname.debug("foo3")}),
		\atk, 5,
		\rel, 5,
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
~p[\hollow].play(vol:0.5);
~p[\hollow].stop(fadeTime:10);
~hollow_win = App.guiHelper(~p[\hollow], "hollow");
~hollow_win.front;

App.saveWorkspace("ws2");

TempoClock.default.tempo_(60/60);

  