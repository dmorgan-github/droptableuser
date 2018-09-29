~bufs = ~bufs ? ();
~bufs[\kik] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/BassDrum/KickDrum0001.aif");
~bufs[\sn] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/SnareDrum/SnareDrum0001-2.aif");
~bufs[\clav] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Misc/Clav.aif");
~bufs[\hiconga] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Hi Conga/Hi Conga0001.aif");
~bufs[\ch] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Cls'd Hihat/Closed Hihat0001.aif");
~bufs[\mc] =  Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Mid Conga/Mid Conga0001.aif");

TempoClock.default.tempo_(120/60);

/////////////////////////////////////////
// kik
(
Pdef(\kik, Pproto({
	~node = Ndef(\kik);
	//~node.play;
}, Pbind(\instrument, \oneshot,
	\buf, ~bufs[\kik],
	\amp, 0.8,
	\dur, 0.25,
	\group, Pfunc({arg evt; evt[\node].group}),
	\out, Pfunc({arg evt; evt[\node].bus.index}),
	\seq, Pseq([
		Pseq([1,0,0,0,  0,0,0,0,  1,0,0,0,  0,0,1,0], 1),
		Pseq(0!16, 1)
	], inf),
	\foo, Pfunc({arg evt;
		if (evt[\seq].coin) {
			1
		} {
			Rest()
		}
	})
)))
)

Ndef(\kik).play(out:0)
Pdef(\kik).play;

/////////////////////////////////////////
// sn
(
Pdef(\sn, Pproto({
	~node = Ndef(\sn);
	//~node.play;
}, Pbind(\instrument, \oneshot,
	\buf, ~bufs[\sn],
	\amp, 0.8,
	\rate, [4,2],
	\dur, 0.25,
	\group, Pfunc({arg evt; evt[\node].group}),
	\out, Pfunc({arg evt; evt[\node].bus.index}),
	\seq, Pseq([
		Pseq([0,0,0,0,  1,0,0,0,  0,0,0,0,  1,0,0,0], 5),
		Pseq( 0!16, 5)
	], inf),
	\foo, Pfunc({arg evt;
		if (evt[\seq].coin) {
			1
		} {
			Rest()
		}
	})
)))
)

Ndef(\sn).play(out:0);
Pdef(\sn).play;


/////////////////////////////////////////
// clav
(
Pdef(\clav, Pproto({
	~node = Ndef(\clav);
	//~node.play;
}, Pbind(\instrument, \oneshot,
	\buf, ~bufs[\clav],
	\amp, 0.5,//Pwhite(0.1,0.2),
	\pan, -0.8,
	\rate, 1.5,
	\dur, 0.25,
	\group, Pfunc({arg evt; evt[\node].group}),
	\out, Pfunc({arg evt; evt[\node].bus.index}),
	\seq, Pseq([
		Pseq([0,0,0,0,  0,0,0,1,  0,0,1,0,  0,0,0,0], 3),
		Pseq(0!16, 3)
	], inf),
	\foo, Pfunc({arg evt;
		if (evt[\seq].coin) {
			1
		} {
			Rest()
		}
	})
)))
)

Ndef(\clav).play(out:0)
Pdef(\clav).play;

/////////////////////////////////////////
// hiconga
(
Pdef(\hiconga, Pproto({
	~node = Ndef(\hiconga);
	//~node.play;
}, Pbind(\instrument, \oneshot,
	\buf, ~bufs[\hiconga],
	\amp, 0.5,
	\pan, 0.8,
	\rate, 1,
	\dur, 0.25,
	\group, Pfunc({arg evt; evt[\node].group}),
	\out, Pfunc({arg evt; evt[\node].bus.index}),
	\seq, Pseq([
		Pseq([0,0,0,0,  0,0,0,0,  0,1,0,0,  0,0,0,0,0], 4),
		Pseq(0!17, 4)
	], inf),
	\foo, Pfunc({arg evt;
		if (evt[\seq].coin) {1} {Rest()}
	})
)))
)

Ndef(\hiconga).play(out:0);
Pdef(\hiconga).play;

/////////////////////////////////////////
// ch
(
Pdef(\ch, Pproto({
	~node = Ndef(\ch)//.play
	.filter(4, {arg in;
		var sig = FbC({arg fb; fb * 0.4 + in}, [3/8, 5/8]) + in;
		sig;
	});
}, Pbind(\instrument, \oneshot,
	\buf, ~bufs[\ch],
	\amp, 1,
	\dur, 0.25,
	\group, Pfunc({arg evt; evt[\node].group}),
	\out, Pfunc({arg evt; evt[\node].bus.index}),
	\seq, Pdefn(\chseq, Pseq([
		Pseq([0,0,1,0,  0,0,1,0,  0,0,1,0,  0,0.7,0,0], 2),
		Pseq(0!16, 2)
	], inf)),
	\foo, Pfunc({arg evt;
		if (evt[\seq].coin) {1} {Rest()}
	}),
	\wet4, Pstutter(16, Pseq([0.4, 0], inf)),
	\set, Pfunc({arg evt;
		var wet = evt[\wet4];
		var group = evt[\group];
		group.set(\wet4, wet);
	})
)))
)

Ndef(\ch).play(out:0);
Pdef(\ch).play


TempoClock.default.tempo_(120/60)

(
Pdef(\test,
	Ptpar([
		0, Pdef(\kik),
		4, Pdef(\sn),
		8, Pdef(\clav),
		16, Pdef(\hiconga),
		32, Pdef(\ch)
	])
).play
)


Ndef(\kik).play(out:0);
Ndef(\sn).play(out:0);
Ndef(\clav).play();
Ndef(\hiconga).play();
Ndef(\ch).play();

Ndef(\kik).stop;
Ndef(\sn).stop;
Ndef(\clav).stop;
Ndef(\hiconga).stop;
Ndef(\ch).stop;

Pdef(\main).play;
Pdef(\main).stop;

/////////////////////////////////////////
// main proxy
~p[\main][0] = \mix -> {Ndef(\kik).ar};
~p[\main][1] = \mix -> {Ndef(\sn).ar}
~p[\main][2] = \mix -> {Ndef(\clav).ar}
~p[\main][3] = \mix -> {Ndef(\hiconga).ar}
~p[\main][4] = \mix -> {Ndef(\ch).ar}
~p[\main].play(out:0);

~p[\main].set(\mix0, 1)
~p[\main].set(\mix1, 1)
~p[\main].set(\mix2, 1)
~p[\main].set(\mix3, 1)
~p[\main].set(\mix4, 0.95)

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

	sig;//DelayC.ar(sig, 0.2, 0.2);
};
);
~p[\mainfx] <<> ~p[\main];
~p[\mainfx].play(out:0, vol:1);
~p[\mainfx].stop;
~mainfx_win = App.guiHelper(~p[\mainfx], "mainfx");
~mainfx_win.front;
