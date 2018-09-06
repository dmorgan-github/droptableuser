//"https://freesound.org/people/Bradovic/sounds/171326/"
~bufs[\piano] = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/ws2/171326__bradovic__piano-improvisation.wav");

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
)

/////////////////////////////////////////
// pattern
(
var numFrames = ~bufs[\piano].numFrames;
var dur = ~bufs[\piano].duration;
Pdef(\glitch_buf, Pbind(
	\instrument, \playbuf_s,
	\buf, ~bufs[\piano],
	\foo, Pseg([0, numFrames], [dur], 0, inf).collect({arg val; if (0.7.coin){val}{\}}),
	// scene 1
	\pos, Pkey(\foo),
	\delta, 1,

	//Pseg([0, numFrames], [dur], 0, inf).collect({arg val; if (0.7.coin){val}{\}}),
	// scene 2
	//\pos, Pif(Pfunc({ 0.5.coin }), Pstutter(Prand([25,35,45], inf), Pkey(\foo)), Pkey(\foo)),
	//\delta, 0.125,

	\dur, Pkey(\delta) * Pwhite(0.5, 2.0, inf),
	\rate, Pfunc({ if (0.4.coin) {-1}{1} * if (0.8.coin) {1} {[12,24,7,-7,5,2].choose.midiratio} * if (0.5.coin){1}{0.5} }),
	\amp, Pif(Pfunc({arg evt; evt[\rate] < 2 }), -12.dbamp, -23.dbamp)
))
)

// scene 1
(
Pdef(\main,
	Pbind(
		\pos, Pkey(\foo),
		\delta, 1) <> Pdef(\glitch_buf)
))

// scene 2
(
Pdef(\main,
	Pbind(
		\pos, Pif(Pfunc({0.5.coin}), Pstutter(Prand([25,35,45], inf), Pkey(\foo)), Pkey(\foo)),
		\delta, 0.125) <> Pdef(\glitch_buf)
))

/////////////////////////////////////////
// glitch_buf node
~p[\glitch_buf].clear;
~p[\glitch_buf].mold;
~p[\glitch_buf][0] = Pdef(\main);
~p[\glitch_buf].play;
~p[\glitch_buf].stop(fadeTime:10);
~glitch_buf_win = App.guiHelper(~p[\glitch_buf], "glitch_buf");
~glitch_buf_win.front;

