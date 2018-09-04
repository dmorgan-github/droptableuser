~bufs[\ring] = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/2018-8-25/22349__studiorat__girls-singing-pish-01.wav")
~bufs[\guitarloop] = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/2018-8-25/48254__digifishmusic__nylon-guitar-loop-b-1.wav");
~bufs[\sing] = Buffer.read(s, "/Users/david/projects/droptableuser/workspaces/2018-8-26/180448__klankbeeld__ghana-woman-sing-traditional-song-dec-1986-2-007-01.wav");

/////////////////////////////////////////
// proxy space
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(60/60);

/////////////////////////////////////////
// grn2
~p[\grn2].clear;
~p[\grn2].mold;
(
var maxOverlap = 12;
var bus = Bus.audio(s, maxOverlap);

~p[\grn2][0] = {

	/*
	var soundBuf = SelectX.kr(
		TIRand.kr(0,1,
			Dust.kr(SinOsc.kr(0.1).range(1,5))),
		[
			DC.kr(~bufs[\ring]),
			DC.kr(~bufs[\guitarloop])
		]
	);
	*/

	var soundBuf = ~bufs[\sing];
	var posLo = \posLo.kr(0.1);
	var posHi = \posHi.kr(0.9);
	var posRateE = \posRateE.kr(0);
	var posRateM = \posRateM.kr(1);
	var overlap = \overlap.kr(2);
	var trigRate = \trigRate.kr(1);
	var rate = \rate.kr(1);
	var bpRQ = \bpRQ.kr(0.1);
	var bpLo = \bpLo.kr(50);
	var bpHi = \bpHi.kr(5000);
	var panMax = \panMax.kr(0.8);
	var amp = \amp.kr(1);

	var sig, bpFreq, dUgen, bufDur, pos, posRate, playbuf, env;
	var index;
	posRate = 10 ** posRateE * posRateM;
	bufDur = BufDur.kr(soundBuf);
	//pos = max(
	//	Phasor.ar(0, BufRateScale.kr(soundBuf) * posRate * SampleDur.ir / bufDur, posLo, posHi),
	//	LFNoise2.kr(1).range(posLo, posHi)
	//);
	index = Env([12, 12, 0],[0, 0.5], 4).kr(gate:Impulse.kr(1));
	pos = PMOsc.kr( 0.005, 2, index ).range(posLo, posHi);

	// multichannel trigger
	env = DXEnvFan.ar(
		Dseq((0..maxOverlap-1), inf),
		trigRate.reciprocal,
		size: maxOverlap,
		maxWidth: maxOverlap,
		width: overlap,
		// option to avoid unwanted triggers
		zeroThr: 0.002,
		// take equalPower = 0 for non-squared sine envelopes
		// more efficient with helper bus
		equalPower: 0,
		bus: bus
    );
	// multichannel playback, pos is triggered for each grain
	playbuf = PlayBuf.ar(1, soundBuf, rate, env, pos * BufFrames.ir(soundBuf), 1);

	dUgen = Dwhite(0, 1);
	// multichannel trigger used to poll values from drate ugen
	bpFreq = Demand.ar(env, 0, dUgen).linlin(0, 1, bpLo, bpHi);

	// generate grains by multiplying with envelope
	sig = playbuf * env;

	sig = sig.collect({arg val, i;
		val;
	});

	// different frequency on each grain channel
	//sig = BPF.ar(sig, bpFreq, bpRQ, (bpRQ ** -1) * (400 / bpFreq ** 0.5));
	// generate array of 5 stereo signals
	sig = Pan2.ar(sig, Demand.ar(env, 0, Dseq([-1, 1], inf) * panMax));

	Splay.ar(sig.asArgsArray.sum) * amp;
};

~p[\grn2].addSpec(\posLo, [0.01, 0.99, \lin, 0.01, 0]);
~p[\grn2].addSpec(\posHi, [0.01, 0.99, \lin, 0.01, 0.5]);
~p[\grn2].addSpec(\posRateE, [-3, 4, \lin, 1, -1]);
~p[\grn2].addSpec(\posRateM, [0.1, 10, \exp, 0.01, 1.35]);
~p[\grn2].addSpec(\trigRate, [1, 200, \lin, 0.01, 90]);
~p[\grn2].addSpec(\overlap, [0.2, 12, \lin, 0.01, 7]);
~p[\grn2].addSpec(\rate, [0.1, 2, \lin, 0.01, 0.75]);
~p[\grn2].addSpec(\panMax, [0.0, 1, \lin, 0.005, 0.75]);
~p[\grn2].addSpec(\bpLo, [100, 5000, \lin, 0, 300]);
~p[\grn2].addSpec(\bpHi, [100, 5000, \lin, 0, 3000]);
~p[\grn2].addSpec(\bpRQ, [0.05, 1, \lin, 0, 0.18]);
~p[\grn2].addSpec(\amp, [0.0, 3, \lin, 0.005, 1]);
);

~p[\grn2].play(fadeTime:5, vol:1);
~p[\grn2].stop(fadeTime:2);
~grn2_win = App.guiHelper(~p[\grn2], "grn2");
~grn2_win.front;

/////////////////////////////////////////
// tap1 : multi tap delay with feedback
~p[\tap1].clear;
(~p[\tap1][0] = {

	var in = \in.ar([0,0]);
	var tap1, tap2, tap3, tap4;
	var fbNode = FbNode(1, 6.5, 4);

	var tap1_delay = \tap1_delay.kr(0.2).lag(0.1);
	var tap2_delay = \tap2_delay.kr(0.5).lag(0.1);
	var tap3_delay = \tap3_delay.kr(0.7).lag(0.1);
	var tap4_delay = \tap4_delay.kr(1).lag(0.1);

	var tap1_mul = \tap1_mul.kr(1).lag(0.1);
	var tap2_mul = \tap2_mul.kr(0.7).lag(0.1);
	var tap3_mul = \tap3_mul.kr(0.5).lag(0.1);
	var tap4_mul = \tap4_mul.kr(0.2).lag(0.1);

	tap1 = PitchShift.ar( fbNode.delay(tap1_delay), 0.5, 2);
	tap2 = fbNode.delay(tap2_delay);
	tap3 = fbNode.delay(tap3_delay);
	tap4 = fbNode.delay(tap4_delay);

	fbNode.write(Mix.ar(in)
		+ (tap1 * \tap1_fb.kr(0).lag(0.1))
		+ (tap2 * \tap2_fb.kr(0).lag(0.1))
		+ (tap3 * \tap3_fb.kr(0).lag(0.1))
		+ (tap4 * \tap4_fb.kr(0).lag(0.1))
	);

	Splay.ar([tap1 * tap1_mul, tap2 * tap2_mul, tap3 * tap3_mul, tap4 * tap4_mul],
		\spread.kr(1),
		center:\center.kr(0)
	);
};

~p[\tap1].addSpec(\tap1_delay, [0, 6, \lin, 0, 0.2]);
~p[\tap1].addSpec(\tap2_delay, [0, 6, \lin, 0, 0.5]);
~p[\tap1].addSpec(\tap3_delay, [0, 6, \lin, 0, 0.7]);
~p[\tap1].addSpec(\tap4_delay, [0, 6, \lin, 0, 1]);

~p[\tap1].addSpec(\tap1_mul, [0, 1, \lin, 0, 1]);
~p[\tap1].addSpec(\tap2_mul, [0, 1, \lin, 0, 0.7]);
~p[\tap1].addSpec(\tap3_mul, [0, 1, \lin, 0, 0.5]);
~p[\tap1].addSpec(\tap4_mul, [0, 1, \lin, 0, 0.2]);

~p[\tap1].addSpec(\tap1_fb, [0, 1, \lin, 0, 0]);
~p[\tap1].addSpec(\tap2_fb, [0, 1, \lin, 0, 0]);
~p[\tap1].addSpec(\tap3_fb, [0, 1, \lin, 0, 0]);
~p[\tap1].addSpec(\tap4_fb, [0, 1, \lin, 0, 0]);

~p[\tap1].addSpec(\spread, [0, 1, \lin, 0, 1]);
~p[\tap1].addSpec(\center, [-1, 1, \lin, 0, 0]);
);
~p[\tap1] <<> ~p[\grn2];
~p[\tap1].play;
~p[\tap1].stop;
(
~p[\tap1].set(
	\tap1_delay, 3/8,
	\tap2_delay, 4/8,
	\tap3_delay, 0,
	\tap4_delay, 0,
	\tap1_mul, 1,
	\tap2_mul, 1,
	\tap3_mul, 0,
	\tap4_mul, 0
);
)
App.guiHelper(~p[\tap1], "tap1").front;

/////////////////////////////////////////
// verb1
~p[\verb1].clear;
(~p[\verb1][0] = {
	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in,
        \t60.kr(1),
        \damp.kr(0),
        \size.kr(1),
        \earlyDiff.kr(0.707),
        \modDepth.kr(0.1),
        \modFreq.kr(0.2),
        \low.kr(1),
        \mid.kr(1),
        \hi.kr(1),
        \lowcut.kr(500),
        \hicut.kr(2000)
    );
    fx;
};
~p[\verb1].addSpec(\t60, [0.0, 60.0, \lin, 0.0, 1]);
~p[\verb1].addSpec(\damp, [0.0, 1, \lin, 0.0, 0]);
~p[\verb1].addSpec(\size, [1, 5, \lin, 0.0, 1]);
~p[\verb1].addSpec(\earlyDiff, [0.0, 1, \lin, 0.0, 0.707]);
~p[\verb1].addSpec(\modDepth, [0.0, 1, \lin, 0.0, 0.1]);
~p[\verb1].addSpec(\modFreq, [0, 10, \lin, 0.0, 0.2]);
~p[\verb1].addSpec(\low, [0, 1, \lin, 0.0, 1]);
~p[\verb1].addSpec(\mid, [0, 1, \lin, 0.0, 1]);
~p[\verb1].addSpec(\hi, [0, 1, \lin, 0.0, 1]);
~p[\verb1].addSpec(\lowcut, [100, 6000, \lin, 0.0, 500]);
~p[\verb1].addSpec(\hicut, [1000, 10000, \lin, 0.0, 1000]);
);
~p[\verb1] <<> ~p[\tap1];
~p[\verb1].play;
~p[\verb1].stop;
App.guiHelper(~p[\verb1], "verb1").front;



/////////////////////////////////////////
// env1
~p[\env1].clear;
(~p[\env1][0] = {

	var trig = Impulse.kr(1);
	var in = \in.ar([0,0]);
	var env = Env.perc.kr(gate:trig);
	PitchShift.ar(in, 0.5, 2) * env;
};
//~p[\env1].addSpec(\param, [0.0, 1.0, \lin, 0.0, 0.4]);
);
~p[\env1] <<> nil~p[\verb1];
~p[\env1].play
~p[\env1].stop;
~env1_win = App.guiHelper(~p[\env1], "env1");
~env1_win.front;

/////////////////////////////////////////
// delay1 : delay with feedback
~p[\delay1].clear;
(~p[\delay1][0] = {
	var in = \in.ar([0,0]);
	var fb = FbC({arg fb;
		fb * \fb.kr(0.2) + in;
	}, [\delayL.kr(3/8), \delayR.kr(5/8)]);
	fb;
};
~p[\delay1].addSpec(\fb, [0.0, 1.0, \lin, 0.0, 0.2]);
~p[\delay1].addSpec(\delayL, [0.001, 5, \lin, 0.0, 3/8]);
~p[\delay1].addSpec(\delayR, [0.001, 5, \lin, 0.0, 5/8]);
);
~p[\delay1] <<> ~p[\env1];
~p[\delay1].play;
~p[\delay1].stop;
App.guiHelper(~p[\delay1], "delay1").front;




App.saveWorkspace(rec:true);
s.stopRecording


