~arp = ();

~arp.rev = 0;

(
~arp.grid = [

	[0,2,4,6],
	[8,9,10,11],
	[4,5,6,7],
	[0,1,2,3]
];
)

(
~arp.pattern = Ptuple([
	Pseq((0..3), inf),
	Pstutter(Pseq([2,4,2], inf), Pseq((0..3), inf))
], inf).asStream;
)

(
~arp.rtn = TaskProxy({

	inf.do({arg i;
		var val;
		var xy = ~arp.pattern.next();
		if (~arp.rev.coin) { xy = xy.reverse };
		val = ~arp.grid[ xy[0] ] [ xy[1] ];
		val.yield;
	});
});
)


~arp.n = NodeProxy.audio.quant_(1.0);
~arp.n.quant = 1.0

(
ProxySynthDef(\arp, {arg freq = 220, t_trig = 1, dur = 1, amp = 0.1;

	var sig, env, fenv, ffreq;
	var sig2;

	freq = Vibrato.ar(K2A.ar(freq.lag(\lag.kr(0.03))), 5, 0.005, 0.2);

	sig = SinOsc.ar(freq, 0.0);

	env = //Decay2.ar(T2A.ar(t_trig));
	Env([0,0,1,0],[0, 0.01, 1].normalizeSum, [-4,4] ).kr(gate:t_trig, timeScale: dur);

	sig = sig * env * AmpCompA.kr(freq) * amp;

	//sig = sig + FbC({arg fb; BPF.ar(sig + fb, freq * 3) * \fb.kr(0.2)}, 0.375);

	//sig = sig + DelayC.ar(sig, 3, 3);

	sig = XFade2.ar(sig, JPverb.ar(sig, 2, 0.5, 3, modDepth: 1), \rev.kr(0).lag(0.1) );

	Splay.ar(sig);

}).add;

~arp.pbind = PbindProxy(
	\scale, Scale.hexSus, //.tuning_(\just),
	\mtranspose, 5,
	\root, 0,
	\degree, ~arp.rtn,
	\octave, 5,
	\mtranspose, 0,
	\delta, 0.25,
	\dur, 1,
	\echo, 0,
	\t_trig, 1,
	\amp, 0.2
);


~arp.player = EventPatternProxy(
	Pchain(Pmono(\arp), ~arp.pbind2)
);

~arp.n[0] = \arp;

~arp.n[10] = \set -> ~arp.pbind;

)

~arp.n.vol = 1
App.record;
~arp.n.play(fadeTime:5);
s.stopRecording;
~arp.n.stop(fadeTime:5);


TempoClock.default.tempo_(1);


~arp.n[10].value.set(\fb, 0.5)

//~arp.player.stop.play;
//~arp.pbind.set(\echo, 1)





