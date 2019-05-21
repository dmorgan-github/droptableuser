//"https://freesound.org/people/Bradovic/sounds/171326/"
~bufs[\piano] = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/ws2/171326__bradovic__piano-improvisation.wav");
"https://freesound.org/people/14G_Panska_Niklova_Michaela/sounds/422137/"
~bufs[\xylo] = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/ws4/422137__14g-panska-niklova-michaela__1-xylophone.wav");
~bufs[\glitch2] = Buffer.alloc(s, 44100 * 16, 2);


~bufs = ();

~p = ProxySpace.new

/////////////////////////////////////////
// recbuf
~p[\recbuf].clear;
~p[\recbuf].mold;
(~p[\recbuf][0] = {
	var in = \in.ar([0,0]);//~p[\pulse].ar;
	var buf = \buf.kr;
    var trig = \trig.tr;
	RecordBuf.ar(in, buf);
	0;
};
//~p[\recbuf].addSpec(\param, [0.0, 1.0, \lin, 0.0, 0.4]);
);
~p[\recbuf] <<> Ndef(\v2);//~p[\pulse];
~p[\recbuf].set(\buf, ~bufs[\glitch2]);
~p[\recbuf].play;
~p[\recbuf].stop;
~recbuf_win = App.guiHelper(~p[\recbuf], "recbuf");
~recbuf_win.front;


TempoClock.default.tempo_(60/60)

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
var buf = ~bufs[\glitch2];
var numFrames = buf.numFrames;
var dur = buf.duration;
Pdef(\glitch_buf, Pbind(
	\instrument, \playbuf_s,
	\buf, buf,
	\foo, Pseg([0, numFrames], [dur], 0, inf).collect({arg val; if (1.coin){val}{Rest()}}),
	\pos, Pkey(\foo),
	\delta, 2,
	\dur, 1,
	\bar, Prand([-12, -7, 12, 24].midiratio, inf),
	\rate, Pfunc({arg evt; if (0.5.coin) {-1}{1} * if (0.5.coin) {evt[\bar]} {1} }),
	\amp, 1,//Pif(Pfunc({arg evt; evt[\rate] < 2 }), -12.dbamp, -30.dbamp)
))
)

/////////////////////////////////////////
// glitch_buf node
~p[\glitch_buf].clear;
~p[\glitch_buf].mold;
~p[\glitch_buf][0] = Pdef(\glitch_buf);
~p[\glitch_buf].play(vol:-18.dbamp);
~p[\glitch_buf].stop(fadeTime:10);

/////////////////////////////////////////
// del2 : delay with feedback
~p[\del2].clear;
(~p[\del2][0] = {
	var in = \in.ar([0,0]);
	//var sig = JPverb.ar(in, 2, 0, 2);
	var sig = in.blend(FbC({arg fb; fb * 0.3 + in}, [3/4, 3/5]), 0.3);
	sig.blend(JPverb.ar(sig, 2, 0, 2), 0.5);
};
~p[\del2].addSpec(\fb, [0.0, 1.0, \lin, 0.0, 0.2]);
~p[\del2].addSpec(\delayL, [0.001, 5, \lin, 0.0, 3/8]);
~p[\del2].addSpec(\delayR, [0.001, 5, \lin, 0.0, 5/8]);
);
~p[\del2] <<> ~p[\glitch_buf];
~p[\del2].play(vol:0.5)
~p[\del2].stop;
~del2_win = App.guiHelper(~p[\del2], "del2");
~del2_win.front;

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

sig = PV_MagMul(chain1, chain2);  // v1 == more sample character (phases of GrainBuf)
    // sig = PV_MagMul(chain2, chain1); // v2 == more synth character (phases of Saw)
    sig = IFFT(sig) * 0.05;

// ten second buffer
~bufs[\warp] = Buffer.alloc(s, 44100 * 10, 2);

~p[\warp] <<> ~p[\pulse];
~p[\warp].set(\buf, ~bufs[\warp], \warpFactor, 0.5, \overlaps, 50, \freqScale, 1, \windowSize, 2);
~p[\warp].play(vol:0.4);
~p[\warp].stop;
~warp_win = App.guiHelper(~p[\warp], "warp");
~warp_win.front;


/////////////////////////////////////////
// delay
~p[\delay2].clear;
(~p[\delay2][0] = {
	var in = \in.ar([0,0]);
	var fx = Greyhole.ar(in);
	fx;//SVF.ar(fx, SinOsc.kr(1/16).range(880, 2200), 0.5);
};
);
~p[\delay2] <<> ~p[\warp];
~p[\delay2].play(vol:0.25);
~p[\delay2].stop;

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
