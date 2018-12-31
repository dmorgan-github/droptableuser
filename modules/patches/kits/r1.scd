(
SynthDef(\oneshot, {
	var buf = \buf.kr(0);
	var rate = \rate.kr(1);
	var sig = PlayBuf.ar(1, buf, rate, loop:0, doneAction:Done.freeSelf);
	sig = Pan2.ar(sig, \pan.kr(0)) * \amp.kr(0.1);
	//sig = Latch.ar(sig, Impulse.ar(LFNoise0.kr(5).lag(0.1).exprange(1000, 16000)));
	OffsetOut.ar(\out.kr(0), sig);
}).add;

SynthDef(\n1, {
	var sig = BPF.ar(WhiteNoise.ar, 10000, 0.1) * Pulse.kr(50);
	var env = Env.perc(\atk.kr(0.01), \rel.kr(0.1), curve:\curve.kr(-4)).kr(gate:1, doneAction:Done.freeSelf);
	sig = Splay.ar(sig) * env * \amp.kr(-6.dbamp);
	sig = Latch.ar(sig, Impulse.ar(LFNoise0.kr(5).lag(0.1).exprange(1000, 16000)));
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\n2, {

	var sig = Klank.ar(`[
		Array.fill(8, { 1200.rand }),
		1,
		1!8
	], WhiteNoise.ar);
	var env = Env.perc(releaseTime:\rel.kr(1)).kr(doneAction:Done.freeSelf);
	sig = Splay.ar(sig) * env * \amp.kr(-6.dbamp);
	sig = Squiz.ar(sig);
	Out.ar(\out.kr(0), sig);

}).add;
)

/////////////////////////////////////////
// sends
(
Ndef(\out2).filter(2, {arg in;
	var sig = in;
	JPverb.ar(sig, 2, 0, 1) * 0.3 + sig;
});

Ndef(\out).filter(2, {arg in;
	var sig = FbC({arg fb; fb * 0.3 + in}, 3/8 * 0.91.reciprocal) * 0.6 + in;
	JPverb.ar(sig, 1, 0, 1) * 0.5 + sig;
});
)

~bufs_volca = ~bufs_volca ? ();
~bufs_volca[\volca_kik] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/volcabeats/bd/BD MPCVB Fat002.wav");
~bufs_volca[\volca_ch] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/volcabeats/ch/HH MPCVB Fat2.wav");
~bufs_volca[\volca_clav] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/volcabeats/cl/Clave MPCVB Fat2.wav");
~bufs_volca[\volca_clap] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/volcabeats/cp/Clap MPCVB Fat3.wav");
~bufs_volca[\volca_sn] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/volcabeats/sd/SD MPCVB Fat005.wav");
~bufs_volca[\volca_hitom] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/volcabeats/tom/Tom MPCVB Fat006.wav");

/////////////////////////////////////////
// volca
(
~bufs_volca.keysValuesDo({arg k, v;
	//Pbindef(k).clear;
	Pbindef(k, \instrument, \oneshot,
		\buf, ~bufs_volca[k],
		\seq, 1,
		\type, Pif(Pkey(\seq) > 0, \note, \rest),
		\dur, 0.25,
		\amp, 0.dbamp
	)
});
)

(
var foo = {
	thisThread.randSeed_(1000000.rand.debug("rand seed: volca"));
	//thisThread.randSeed_(62491);
}.();

var pdefs = [
	\volca_kik -> [1,0,0,0],
	\volca_sn -> Array.fill(16, { if (0.2.coin) {1}{0} }),
	\volca_ch -> Array.fill(16, { if (0.7.coin) {1}{0} }),
	\volca_clav -> Array.fill(16, {if (0.2.coin) {1}{0}})
].collect({arg val;
	var node = ~p[val.key];
	Pdef(val.key.identityHash, {
		node.play;
		Pbindef(val.key, \seq, Pseq(val.value, inf), \out, Pfunc({node.bus.index}), \group, Pfunc({node.group}))
	})
});

// NOTE:
// can pass args to pattern like this
// (Pdef(\r2) <> (vol:0.1)).play
Pdef(\r2, {arg vol = 0.25;
	Ppar(pdefs, inf)
});
)

Pdef(\r2).play;
Pdef(\r2).stop;



/////////////////////////////////////////
// r1
Pbindef(\n1).clear;
(
Pbindef(\n1, \instrument, \n1,
	\seq, 1,
	\type, Pif(Pkey(\seq) > 0, \note, \rest),
	\hpf, 4200,
	\rel, 0.1, //Prand([0.1, 0.3, 0.2, 0.5, 1], inf),
	\dur, 0.25,
	\amp, 0.dbamp
)
)

Pbindef(\n2).clear;
(
Pbindef(\n2, \instrument, \n2,
	\seq, 1,
	\type, Pif(Pkey(\seq) > 0, \note, \rest),
	\dur, 0.25,
	\rel, 0.1,
	\amp, -40.dbamp
)
)

(
var foo = {
	thisThread.randSeed_(1000000.rand.debug("rand seed"));
	//thisThread.randSeed_(129733);
}.();

var pdefs = [
	\n1 -> [1,0,0,0],
	\n2 -> Array.fill(16, { if (0.2.coin) {1}{0} })
].collect({arg val;
	var node = ~p[val.key];
	Pdef(val.key.identityHash.asSymbol, {
		node.play;
		Pbindef(val.key, \seq, Pseq(val.value, inf), \out, Pfunc({node.bus.index}), \group, Pfunc({node.group}));
	});
});

Pdef(\r1, Ppar(pdefs, inf))
)

Pdef(\r1).play;
Pdef(\r1).stop;

App.saveWorkspace("ws18", rec:true);
s.stopRecording;


