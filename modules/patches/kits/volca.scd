~bufs = ~bufs ? ();
~bufs[\volca_kik] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/volcabeats/bd/BD MPCVB Fat002.wav");
~bufs[\volca_ch] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/volcabeats/ch/HH MPCVB Fat2.wav");
~bufs[\volca_clav] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/volcabeats/cl/Clave MPCVB Fat2.wav");
~bufs[\volca_clap] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/volcabeats/cp/Clap MPCVB Fat3.wav");
~bufs[\volca_sn] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/volcabeats/sd/SD MPCVB Fat005.wav");
~bufs[\volca_hitom] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/volcabeats/tom/Tom MPCVB Fat006.wav");

/////////////////////////////////////////
// kik
(
Pdef(\volca_kik, Pproto({
	~node = Ndef(\volca_kik);
}, Pbind(\instrument, \oneshot,
	\buf, ~bufs[\volca_kik],
	\amp, 0.8,
	\dur, 0.25,
	\group, Pfunc({arg evt; evt[\node].group}),
	\out, Pfunc({arg evt; evt[\node].bus.index}),
	\seq, Pdefn(\volca_kikseq, Pseq([1,0,0,0,  0,0,0,0,  1,0,0,0,  0,0,1,0], inf)),
	\foo, Pfunc({arg evt; if (evt[\seq].coin) {1} {Rest()}})
)))
)

Pdef(\volca_kik).play;
Ndef(\volca_kik).play;

/////////////////////////////////////////
// sn
(
Pdef(\volca_sn, Pproto({
	~node = Ndef(\volca_sn);
}, Pbind(\instrument, \oneshot,
	\buf, ~bufs[\volca_sn],
	\amp, 0.8,
	\rate, [4,2],
	\dur, 0.25,
	\group, Pfunc({arg evt; evt[\node].group}),
	\out, Pfunc({arg evt; evt[\node].bus.index}),
	\seq, Pdefn(\volca_snseq, Pseq([0,0,0,0,  1,0,0,0,  0,0,0,0,  1,0,0,0], inf)),
	\foo, Pfunc({arg evt; if (evt[\seq].coin) {1} {Rest()}})
)))
)

Pdef(\volca_sn).play;
Ndef(\volca_sn).play;

/////////////////////////////////////////
// clav
(
Pdef(\volca_clav, Pproto({
	~node = Ndef(\volca_clav);
}, Pbind(\instrument, \oneshot,
	\buf, ~bufs[\volca_clav],
	\amp, 0.5,//Pwhite(0.1,0.2),
	\pan, -0.8,
	\rate, 1.5,
	\dur, 0.25,
	\group, Pfunc({arg evt; evt[\node].group}),
	\out, Pfunc({arg evt; evt[\node].bus.index}),
	\seq, Pdefn(\volca_clavseq, Pseq([0,0,0,0,  0,0,0,1,  0,0,1,0,  0,0,0,0], inf)),
	\foo, Pfunc({arg evt; if (evt[\seq].coin) {1} {Rest()}})
)))
)

Ndef(\volca_clav).play(out:0);
Pdef(\volca_clav).play;

/////////////////////////////////////////
// ch
(
Pdef(\volca_ch, Pproto({
	~node = Ndef(\volca_ch)//.play
	.filter(4, {arg in;
		var sig = FbC({arg fb; fb * 0.4 + in}, [3/8, 5/8]) + in;
		sig;
	});
}, Pbind(\instrument, \oneshot,
	\buf, ~bufs[\volca_ch],
	\amp, 1,
	\dur, 0.25,
	\group, Pfunc({arg evt; evt[\node].group}),
	\out, Pfunc({arg evt; evt[\node].bus.index}),
	\seq, Pdefn(\volca_chseq, Pseq([0,0,1,0,  0,0,1,0,  0,0,1,0,  0,0.7,0,0], inf)),
	\foo, Pfunc({arg evt; if (evt[\seq].coin) {1} {Rest()}}),
	\wet4, Pstutter(16, Pseq([0.4, 0], inf)),
	\set, Pfunc({arg evt;
		var wet = evt[\wet4];
		var group = evt[\group];
		group.set(\wet4, wet);
	})
)))
)

Ndef(\volca_ch).play(out:0);
Pdef(\volca_ch).play;

/////////////////////////////////////////
// hi tom
(
Pdef(\volca_hitom, Pproto({
	~node = Ndef(\volca_hitom);
}, Pbind(\instrument, \oneshot,
	\buf, ~bufs[\volca_hitom],
	\amp, 2,
	\dur, 0.125,
	\group, Pfunc({arg evt; evt[\node].group}),
	\out, Pfunc({arg evt; evt[\node].bus.index}),
	\seq, Pdefn(\volca_hitomseq, Pseq([0,0,1,0,  0,0,1,0,  0,0,1,0,  0,0.7,0,0], inf)),
	\foo, Pfunc({arg evt; if (evt[\seq].coin) {1} {Rest()}}),
)))
)

Ndef(\volca_hitom).play(out:0);
Pdef(\volca_hitom).play;


TempoClock.default.tempo_(120/60);

/////////////////////////////////////////
// patterns
(
var seqs = [
	\volca_kik ->      [1,0,0,0,  0,0,0,0,  1,0,0,0,  0,0,1,0],
	\volca_sn ->       [0,0,0,0,  1,0,0,0,  0,0,0,0,  1,0,0,0],
	\volca_ch ->       [0,0,1,0,  0,0,1,0,  0,0,1,0,  0,0.7,0,0],
	\volca_clav ->     [0,0,0,0,  0,0,0,1,  0,0,1,0,  0,0,0,0],
	\volca_hitom ->       [0,0,1,0,  0,0,1,0,  0,0,1,0,  0,0.7,0,0]
];

seqs.do({arg val;
	var key = (val.key ++ 'seq').asSymbol;
	var seq = val.value;
	Pdefn(key, Pseq(seq, inf));
});
)

/////////////////////////////////////////
// scenes
(
var foo = {~p[\mix].clear}.();
var keys = [\volca_kik, \volca_sn, \volca_ch, \volca_clav, \volca_hitom];
var pdefs;

keys.do({arg key, i;
	var node = Ndef(key);
	~p[\mix][i] = \mix -> {node.ar;};
});

pdefs = keys.collect({arg key;
	Pdef(key)
});

Pdef(\scene1,
	Ppar(pdefs, inf)
);
);

(
Pdef(\test, {

	Pseq([
		Pfindur(8, Pdef(\scene1)),
		Pfindur(2, Pdef(\rest))
	], inf)

}).play
)

Pdef(\scene1).play;
Pdef(\scene1).stop;
~p[\mix].play(vol:0.2);
~p[\mix].stop;
~p[\mainfx].play(vol:0.8);
~p[\mainfx].stop;


/////////////////////////////////////////
// mainfx
~p[\mainfx].clear;
(~p[\mainfx][0] = {

	var in = \in.ar([0,0]);
	var sig = in;

	sig = Decimator.ar(sig, 44100/8, LFDNoise3.kr(1/3).range(8,12));//}.dup(4).sum;
	sig = RunningSum.rms(sig, 20);
	sig = FreqShift.ar(sig, [-3,3]);
	sig = LeakDC.ar(sig);

	sig;
};
);
~p[\mainfx] <<> ~p[\mix];
~p[\mainfx].play(out:0, vol:0.8);
~p[\mainfx].stop;
~mainfx_win = App.guiHelper(~p[\mainfx], "mainfx");
~mainfx_win.front;
