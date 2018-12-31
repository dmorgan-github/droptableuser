(
SynthDef(\oneshot, {
	var buf = \buf.kr(0);
	var rate = \rate.kr(1);
	var sig = PlayBuf.ar(1, buf, rate, loop:0, doneAction:Done.freeSelf);
	sig = Pan2.ar(sig, \pan.kr(0)) * \amp.kr(0.1);
	//sig = Latch.ar(sig, Impulse.ar(LFNoise0.kr(5).lag(0.1).exprange(1000, 16000)));
	OffsetOut.ar(\out.kr(0), sig);
}).add;
)

~kit_bufs = ~kit_bufs ? ();
~kit_bufs[\b1] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/perc1/agogo/agogo aigu fermÇ.wav");
~kit_bufs[\b2] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/perc1/conga/Conga aigu slap.wav");
~kit_bufs[\b3] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/perc1/electric/drum4fingersn.wav");
~kit_bufs[\b4] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/perc1/timbale/timables ouvert.wav");


/////////////////////////////////////////
// instrs
(
~kit_bufs.keysValuesDo({arg k, v;
	//Pbindef(k).clear;
	Pbindef(k, \instrument, \oneshot,
		\buf, ~kit_bufs[k],
		\seq, 1,
		\type, Pif(Pkey(\seq) > 0, \note, \rest),
		\dur, 0.25,
		\amp, 0.dbamp
	)
});
)

(
var foo = {
	thisThread.randSeed_(1000000.rand.debug("rand seed"));
	//thisThread.randSeed_(62491);
}.();

var pdefs = [
	\b1 -> [1,0,0,0],
	\b2 -> Array.fill(17, { if (0.2.coin) {1}{0} }),
	\b3 -> Array.fill(19, { if (0.2.coin) {1}{0} }),
	\b4 -> Array.fill(15, {if (0.2.coin) {1}{0}})
].collect({arg val;
	var node = ~p[val.key];
	Pdef(('pdef_' ++ val.key).asSymbol, {
		node.play;
		Pbindef(val.key, \seq, Pseq(val.value, inf), \out, Pfunc({node.bus.index}), \group, Pfunc({node.group}))
	})
});

// NOTE:
// can pass args to pattern like this
// (Pdef(\r2) <> (vol:0.1)).play
Pdef(\r2, {
	Ppar(pdefs, inf)
});
)

Pdef(\r2).play;
Pdef(\r2).stop;


~p[\bobo].play;
~p[\bobo][4] = nil
(
~p[\bobo].filter(10, {arg in;

	var fb = FbC({arg fb;
		var sig = fb * \fb.kr(0.7) + in;
		sig = PitchShift.ar(sig, 0.5, SinOsc.kr(1/4).range(2,7).midiratio);
		sig = FreqShift.ar(sig, [-100, 100]);
		//sig = JPverb.ar(sig, 10, 0, SinOsc.kr(1/8).range(1,2)) * 0.2 + sig;
		sig;
	}, 4, 0.1);

	var sig = Splay.ar(fb);
	sig = FbC({arg fb; fb * 0.3 + sig}, [3/8, 5/8]) * 0.7 + sig;
	sig = BLowPass4.ar(sig, SinOsc.kr(4).range(2200, 4400), 0.2);
	sig = JPverb.ar(sig, 6, 0, 5) * 0.3 + sig;
	sig;
})
)

~p[\b1].play;
~p[\b2].play;
~p[\b3].play;
~p[\b4].play;

~p[\b1].stop;
~p[\b2].stop;
~p[\b3].stop;
~p[\b4].stop;

~p[\bobo][0] = \mix -> {~p[\b1]};
~p[\bobo][1] = \mix -> {~p[\b2]};
~p[\bobo][2] = \mix -> {~p[\b3]};
~p[\bobo][3] = \mix -> {~p[\b4]};


