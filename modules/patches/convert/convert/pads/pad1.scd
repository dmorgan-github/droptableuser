(
ProxySynthDef(\pad1, {

	var amp = \amp.kr(0.1);
	var freq = \freq.kr(440);
	var env = Env.linen(
		attackTime: \atk.kr(0.01),
		sustainTime: \sus.kr(1),
		releaseTime: \rel.kr(1)).kr();
	var sig = COsc.ar(HarmLib.at(\square),
		Vibrato.ar(K2A.ar([freq, freq * 0.501, freq * 2.01]), \vrate.kr(6), \vdepth.kr(0.01) ), 0.1 ) !2;

	sig = BLowPass4.ar(sig, SinOsc.kr(0.05).range(660, 880), 0.5).sum;

	sig * env * amp * AmpCompA.kr(freq);

}).add;
)

///////////////////////////////////////////
~pad1 = App.polyDevice(\pad1);
(~pad1.pattern.set(
	\scale, Scale.ritusen,
	\octave, Prand([4, 5, 6], inf),
	\degree, Pwhite(0, 5, inf).clump(2),
	\delta, Prand([2, 4], inf),
	\sustain, Pkey(\delta) * 2,
	\atk, 2,
	\sus, 2,
	\vrate, 5,
	\amp, 0.08
));
(~pad1.node[10] = \filter -> {arg in;
	Greyhole.ar(in, delayTime:2, feedback: 0.7);
});

~pad1.node.vol = 0.05;
~pad1.player.play;
~pad1.player.stop;
~pad1.node.stop(10);