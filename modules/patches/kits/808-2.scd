(
SynthDef(\oneshot, {

	var buf = \buf.kr(0);
	var rate = \rate.kr(1);
	var sig = PlayBuf.ar(1, buf, rate, loop:0, doneAction:2);
	sig = Pan2.ar(sig, \pan.kr(0)) * \amp.kr(0.1);

	OffsetOut.ar(\out.kr(0), sig);

}).add;
)

~bufs = ~bufs ? ();
~bufs[\kik] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/BassDrum/KickDrum0001.aif");
~bufs[\sn] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/SnareDrum/SnareDrum0001-2.aif");
~bufs[\clav] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Misc/Clav.aif");
~bufs[\hiconga] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Hi Conga/Hi Conga0001.aif");
~bufs[\ch] = Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Cls'd Hihat/Closed Hihat0001.aif");
~bufs[\mc] =  Buffer.read(s, "/Users/david/projects/droptableuser/samples/1channel/drums/Roland TR-808 Normalised/Mid Conga/Mid Conga0001.aif");


(
~bind = {arg pattern;
	Prout({
		var seq = pattern.asStream;
		inf.do({
			var val = seq.next;
			val = if (val.coin) {1}{Rest()};
			val.yield;
		});
	})
};
~build_track = {arg key;
	var node = Ndef(key);
	Pdef(key, Pbind(\instrument, \oneshot,
		\buf, ~bufs[key],
		\group, Pfunc({arg evt; node.group}),
		\out, Pfunc({arg evt; node.bus.index}),
		\dur, 1,
		\amp, 0.dbamp
	))
};
~build_mix = {arg keys;
	keys.do({arg key, i;
		~p[\mix][i] = \mix -> {Ndef(key)}
	});
	~p[\mix];
};
~build_kit = {arg keys;
	keys.do({arg key, i;
		~build_track.(key);
	});
	~build_mix.(keys);
};
~build_scene = {arg scene, vals;

	var result = vals.collect({arg val, i;
		var key = val.key;
		var pattern = val.value;
		var pdef = ~build_track.(key);
		var scenekey = (key ++ '_' ++ scene).asSymbol;
		Pdef(scenekey, pattern <> pdef);
	});

	var keys = vals.collect({arg val; val.key});
	~build_mix.(keys);
	Ppar(result, inf);
};
)

~mix = ~build_kit.([\kik, \sn]);
~mix.play;

(
var scene1 = [
	\kik -> Pbind(
		\dur, 0.125,
		\foo, ~bind.(Pseq([1,0,0,0, 1,0,0,0, 1,0,0,0, 0,0,1,0], inf))
	),
	\sn -> Pbind(
		\dur, 0.125,
		\foo, ~bind.(Pseq([0,0,0,0, 1,0,0,0, 0,0,0,0, 1,0,0,0], inf))
	)
];

)

(
Pdef(\kik_a, Pbind(
	\dur, 0.125,
	\foo, ~bind.(Pseq([1,0,0,0, 1,0,0,0, 1,0,0,0, 0,0,1,0], inf))
) <> Pdef(\kik))
)

Ndef(\kik).play;
Pdef(\kik_a).play;
Pdef(\sn).play;

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
