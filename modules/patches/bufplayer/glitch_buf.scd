//"https://freesound.org/people/Bradovic/sounds/171326/"
~bufs[\piano] = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/ws2/171326__bradovic__piano-improvisation.wav");
"https://freesound.org/people/14G_Panska_Niklova_Michaela/sounds/422137/"
~bufs[\xylo] = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/ws4/422137__14g-panska-niklova-michaela__1-xylophone.wav");

/////////////////////////////////////////
// synth
(
SynthDef(\playbuf_s, {

	var numChannels = 2;
	var buf = \buf.kr;
	var rate = \rate.kr(1);
	var startPos = \pos.kr(0);
	var loop = \loop.kr(0);
	var dur = \dur.kr(1);
	var sig = PlayBuf.ar(numChannels, buf, rate, 1, startPos, loop);
	var env = Env([0,1,1,0], [0,dur,0.01], curve:\step).kr(doneAction:Done.freeSelf);
	sig = sig * env * \amp.kr(-12.dbamp);
	sig = Balance2.ar(sig[0], sig[1], \pan.kr(0));
	Out.ar(\out.kr(0), sig);

}).add;

SynthDef(\playbuf_m, {

	var numChannels = 1;
	var buf = \buf.kr;
	var rate = \rate.kr(1);
	var startPos = \pos.kr(0);
	var loop = \loop.kr(0);
	var dur = \dur.kr(1);
	var sig = PlayBuf.ar(numChannels, buf, rate, 1, startPos, loop);
	var env = Env([0,1,1,0], [0,dur,0.01], curve:\step).kr(doneAction:Done.freeSelf);
	sig = sig * env * \amp.kr(-12.dbamp);
	sig = Splay.ar(sig);
	Out.ar(\out.kr(0), sig);

}).add;
)

/////////////////////////////////////////
// pattern
(
var buf = ~buf;//~bufs[\arp];//~bufs[\xylo];
var numFrames = buf.numFrames;
var dur = buf.duration;
Pdef(\glitch_buf, Pbind(
	\instrument, \playbuf_m,
	\buf, buf,
	\foo, Pseg([0, numFrames], [dur], 0, inf).collect({arg val; if (0.7.coin){val}{Rest()}}),
	\pos, Pkey(\foo),
	\delta, 0.5,
	\dur, Pkey(\delta) * Pwhite(0.5, 2.0, inf),
	\bar, Pxrand([12,24,7,5].midiratio, inf),
	\rate, Pfunc({arg evt; if (0.6.coin) {1}{-1} * if (0.7.coin) {1} {evt[\bar]} }), // reverse is tricky
	\amp, 1,//Pif(Pfunc({arg evt; evt[\rate] < 2 }), -12.dbamp, -30.dbamp)
))
)

/////////////////////////////////////////
// glitch_buf node
~p[\glitch_buf].clear;
~p[\glitch_buf].mold;
~p[\glitch_buf][0] = Pdef(\glitch_buf);
~p[\glitch_buf].play(vol:0.2);
~p[\glitch_buf].stop(fadeTime:10);

(
~p[\glitch_buf].filter(4, {arg in;
	JPverb.ar(in, 5, 0, 5) * 0.6 + in;
});
)

/////////////////////////////////////////
// warp
~p[\warp].clear;
(~p[\warp][0] = {

	var x, y;
	var in = \in.ar([0,0]);
	var buffer = \buf.kr(0);
	var warpFactor = \warpFactor.kr(1);
	var freqScale = \freqScale.kr(1);
	var windowSize = \windowSize.kr(0.2);
	var envbufnum = \envbufnum.kr(-1);
	var overlaps = \overlaps.kr(10);
	var windowRandRatio = \windowRandRatio.kr(0.1);
	var preLevel = \preLevel.kr(0);

	var numChannels = in.asArray.size;
	var pointer = LFSaw.kr(warpFactor * BufDur.kr(buffer).reciprocal, 1, 0.5, 0.5 );
	var record = RecordBuf.ar(in, buffer, preLevel: preLevel, loop: 0);

	var fx = Warp1.ar(numChannels,
		buffer,
		pointer,
		freqScale,
		windowSize,
		envbufnum,
		overlaps,
		windowRandRatio,
		4
	);

	#x, y = Rotate2.ar(fx[0], fx[1], LFSaw.kr(\rate.kr(0.1)));
	[x,y];
};
~p[\warp].addSpec(\warpFactor, [0.1, 250, \lin, 0.0, 1]);
~p[\warp].addSpec(\freqScale, [0.1, 4, \lin, 0.0, 1]);
~p[\warp].addSpec(\windowSize, [0.1, 4, \lin, 0.0, 0.2]);
~p[\warp].addSpec(\overlaps, [0, 250, \lin, 0.0, 10]);
~p[\warp].addSpec(\windowRandRatio, [0, 1, \lin, 0.0, 0.1]);
~p[\warp].addSpec(\preLevel, [0, 1, \lin, 0.0, 0]);
);

// ten second buffer
~bufs[\warp] = Buffer.alloc(s, 44100 * 10, 2);

~p[\warp] <<> ~p[\glitch_buf];
~p[\warp].set(\buf, ~bufs[\warp], \warpFactor, 0.1, \overlaps, 50, \freqScale, -7.midiratio, \windowSize, 1);
~p[\warp].play(vol:0.5);
~p[\warp].stop;
~warp_win = App.guiHelper(~p[\warp], "warp");
~warp_win.front;


PV_PhaseShift

/////////////////////////////////////////
// delay
~p[\delay].clear;
(~p[\delay][0] = {
	var in = \in.ar([0,0]);
	var fx = FbC({arg fb; fb * 0.5 + in}, [3/8, 5/8]);
	fx
};
);
~p[\delay] <<> ~p[\glitch_buf];
~p[\delay].play(vol:0.8);
~p[\delay].stop;

/////////////////////////////////////////
// reverb
~p[\reverb].clear;
(~p[\reverb][0] = {
	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in, 5, 0, SinOsc.kr(1/32).range(4,5));
	fx;
};
);
~p[\reverb] <<> ~p[\delay];
~p[\reverb].play(vol:0.5);
~p[\reverb].stop;

/////////////////////////////////////////
// play
(
~p[\glitch_buf].play(fadeTime:0);
~p[\delay].play(fadeTime:10, vol:0.8);
~p[\reverb].play(fadeTime:10, vol:0.5);
)

/////////////////////////////////////////
// scenes
// scene 1
(
Pdef(\main, Pbind(
	\pos, Pkey(\foo),
	\delta, 0.5) <> Pdef(\glitch_buf)
))

// scene 2
(
Pdef(\main, Pbind(
	\pos, Pif(Pfunc({0.5.coin}), Pstutter(Prand([25,35,45], inf), Pkey(\foo)), Pkey(\foo)),
	\delta, 0.25) <> Pdef(\glitch_buf)
))

/////////////////////////////////////////
// stop
(
~p[\reverb].stop;
~p[\delay].stop;
~p[\glitch_buf].stop;
)
