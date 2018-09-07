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
	\foo, Pseg([0, numFrames], [dur], 0, inf).collect({arg val; if (0.4.coin){val}{Rest()}}),
	\pos, Pkey(\foo),
	\delta, 1,
	\dur, Pkey(\delta) * Pwhite(0.5, 2.0, inf),
	\bar, Pxrand([12,24,7,5].midiratio, inf),
	\rate, Pfunc({arg evt; if (0.6.coin) {1}{-1} * if (0.7.coin) {1} {evt[\bar]} }),
	\amp, Pif(Pfunc({arg evt; evt[\rate] < 2 }), -12.dbamp, -30.dbamp)
))
)

/////////////////////////////////////////
// glitch_buf node
~p[\glitch_buf].clear;
~p[\glitch_buf].mold;
~p[\glitch_buf][0] = Pdef(\main);
~p[\glitch_buf].play;
~p[\glitch_buf].stop(fadeTime:10);

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
