(
SynthDef(\oneshot, {
	var buf = \buf.kr(0);
	var rate = \rate.kr(1);
	var sig = PlayBuf.ar(1, buf, rate, loop:0, doneAction:Done.freeSelf);
	sig = Pan2.ar(sig, \pan.kr(0)) * \amp.kr(0.1);
	OffsetOut.ar(\out.kr(0), sig);
}).add;
)

~bufs_808 = ~bufs_808 ? ();
~bufs_808[\kik_808] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/BassDrum/KickDrum0001.aif");
~bufs_808[\sn_808] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/SnareDrum/SnareDrum0001-2.aif");
~bufs_808[\clav_808] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Misc/Clav.aif");
~bufs_808[\hiconga_808] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Hi Conga/Hi Conga0001.aif");
~bufs_808[\ch_808] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Cls'd Hihat/Closed Hihat0001.aif");
~bufs_808[\mc_808] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Mid Conga/Mid Conga0001.aif");
~bufs_808[\cl_808] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Misc/Clap.aif");
~bufs_808[\cb_808] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Misc/Cowbell.aif");
~bufs_808[\mar_808] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Misc/Maraca.aif");
~bufs_808[\rim_808] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Misc/Rimshot.aif");
~bufs_808[\hitom_808] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Hi Tom/Hi Tom0001.aif");
~bufs_808[\cy_808] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/CYmbal/CYmbal0001.aif");
~bufs_808[\loconga_808] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Low Conga/Low Conga0001.aif");
~bufs_808[\lotom_808] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Low Tom/Low Tom0001.aif");
~bufs_808[\oh_808] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Open Hihat/Open Hihat0001.aif");


^Pbind(
			\dur, grid * (2/tuplet),
			\amp, Pseq(sequence, repeats),
			\type, Pif(Pkey(\amp) > 0, \note, \rest)
		)

/////////////////////////////////////////
// pbinds
(
~bufs_808.keysValuesDo({arg k, v;
	Pbindef(k).clear;
	Pbindef(k, \instrument, \oneshot,
		\buf, ~bufs_808[k],
		\amp, 0.8,
		\dur, 0.25,
		\seq, Pseq([1,0,0,0,  0,0,0,0,  1,0,0,0,  0,0,1,0], inf),
		\foo, Pfunc({arg evt; if (evt[\seq].coin) {1} {Rest()}})
	)
})
)


/////////////////////////////////////////
// scene
(
var pdefs = [
	\kik_808 ->      [1,0,0,0,  0,0,0,0,  1,0,0,0,  0,0,1,0],
	\sn_808 ->       [0,0,0,0,  1,0,0,0,  0,0,0,0,  1,0,0,0],
	\ch_808 ->       Array.fill(18, { if(0.5.coin){0.5}{0} }).pyramid,
	\hiconga_808 ->  Array.fill(18, { if(0.8.coin){0.5}{0} }),
].collect({arg val, i;
	Pbindef(val.key, \seq, Pseq(val.value, inf));
});

Pdef(\scene1_808).clear;
Pdef(\scene1_808,
	Ppar(pdefs, inf)
);
)

Pdef(\scene1_808).play;

