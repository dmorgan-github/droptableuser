~p = ProxySpace.new(s);
~p.quant = 1.0;


Main.elapsedTime
Dlace




(~p[\test] = {
	var freq = \freq.kr;
	var trig = \trig.tr;
	[trig, freq];
});
(~p[\test][4] = Task({
	inf.do({
		~p[\test].set(\freq, rrand(0,100));
		1.wait;
	});
}));

~p[\test][4].resume


/////////////////////////////////
// main sequencer
(~p[\seq1] = {
	var freq = \freq.kr;
	var trig = \trig.tr;
	[trig, freq];
});
(~p[\seq1][4] = \set -> Pbind(
	\trig, 1,
	\scale, Scale.kumoi,
	\degree, Ppatlace([Pseq([0,6], inf), Pseq([1,3,5,4], inf)], inf),
	\octave, 4,
	\delta, 0.125,
	\isRest, false, //Pwrand([true, false], [0.7,0.3], inf)
));


/////////////////////////////////
// trig
~p[\trig1].clear;
~p[\trig1] = {~p[\seq1].kr[0]}

/////////////////////////////////
// freq
~p[\freq].clear;
~p[\freq] = {~p[\seq1].kr[1]};

/////////////////////////////////
// env
~p[\env1] = ~tperc.();
~p[\env1].set(\trig, ~p[\trig1], \rel, 0.2);

/////////////////////////////////
// lfo 1
~p[\lfo1] = ~lfo.(wave:\sin, freq:10, min:0, max:1)
~p[\lfo1].set(\freq, 50)

/////////////////////////////////
// t line
~p[\l1] = ~tline.(dur: 0.1, start: 4, end: 0);
~p[\l1].set(\trig, ~p[\trig1], \dur, 1, \start, 3, \end, 1.1)

//~p[\l2] = ~tline.(dur: 0.1, start: 6, end: 0)
~tlinen.argNames
~tlinen.def.sourceCode
~p[\l2] = ~tlinen.(func:{arg env; env.range(0.1, 3)})
~p[\l2].set(\trig, ~p[\trig1], \curve, -4, \atk, 0.1, \sus, 1, \rel, 0.1)

~p[\l3] = ~tline.(dur: 0.1, start: 8, end: 0);
~p[\l3].set(\trig, ~p[\trig1], \dur, 0.1, \start, 1, \end, 0.1, \curve, 0)


~p[\env2] = ~tlinen.()
~p[\env2].set(\trig, ~p[\trig1], \sus, 1);

~p[\env3] = ~tperc.()
~p[\env3].set(\trig, ~p[\trig1], \rel, 0.01);

~p[\env4] = ~tperc.()
~p[\env4].set(\trig, ~p[\trig1], \atk, 0.5, \rel, 0.01, \curve, 0);

~p[\env5] = ~tperc.()
~p[\env5].set(\trig, ~p[\trig1], \atk, 0.01, \rel, 0.01, \curve, 0);


////////////////////////////////
//[ [ 0, 1, 1 ], [ 1, 2, 1 ], [ 3, 4, 1 ], [ 3, 5, 1 ], [ 5, 5, an OutputProxy ] ]
//[ 0, 3 ]
~fm7.def.sourceCode
~p[\s1] = ~fm7.(algo:10);
(~p[\s1].set(

	\freq, ~p[\freq],

	\f0, 1.01,
	\f1, 2.01,
	\f2, 4.01,
	\f3, 2.0,
	\f4, 3.11,
	\f5, 2.01,

	\f0amp, 1,
	\f1amp, ~p[\env2],
	\f2amp, ~p[\env3],
	\f3amp, 1,
	\f4amp, ~p[\env4],
	\f5amp, ~p[\env5],

	\fb, 1,

	\amp, ~p[\env1]
))

~p[\s1].play;
~p[\s1].stop;

~p[\stereo] = ~sum.(chans:~p[\s1].numChannels);
~p[\stereo] <<> ~p[\s1];
~p[\stereo].play
~p[\stereo].stop

~p[\delay] = ~delayorama.(chans:~p[\stereo].numChannels);
~p[\delay] <<> ~p[\stereo]
~p[\delay].set(\wet, 0.4)
~p[\delay].play
~p[\delay].stop
~p[\delay].gui;
~p[\delay].vol = 0.1

~p[\verb] = ~jpverb.(chans:~p[\delay].numChannels);
~p[\verb] <<> ~p[\delay];
~p[\verb].set(\wet, 0.3)
~p[\verb].play;
~p[\verb].stop;
~p[\verb].vol = 0.2;

~p[\dist] = ~barrys.(chans:~p[\delay].numChannels);
~p[\dist] <<> ~p[\delay];
~p[\dist].play
~p[\dist].stop
~p[\dist].vol = 0.2
~p[\dist].gui;

~p[\ps] = ~pitch_shift.(chans:~p[\dist].numChannels);
~p[\ps].set(\pitchratio, 2, \windowsize, 0.1, \pitchdisp, 0.1, \timedisp, 0.1, \wet, 0.3);
~p[\ps] <<> ~p[\dist];
~p[\ps].stop

~p[\gverb] = ~gverb.(roomsize:50);
~p[\gverb] <<> ~p[\ps];//~p[\dist];
~p[\gverb].play
~p[\gverb].stop;
~p[\gverb].vol = 0.15


~h = ~ps_helper.(~p);
~h.ls_monitor();

/////////////////////////////////////////////////////////
//
(~p[\s2] = {

	var freq = Vibrato.ar(K2A.ar(\freq.kr(432).lag(\lag.kr(0.0))),
		\vrate.kr(6),
		\vdepth.kr(0.0),
		\vdelay.kr(0),
		\vonset.kr(0),
		\vrateVar.kr(0.04),
		\vdepthVar.kr(0.1)
	);

	var in = \in.ar([0,0]);

	var numFreqs = 6;

	var detune = \detune.kr(0);

	var ffreqs = (0..numFreqs-1).collect({arg i;
		 (\f ++ i).asSymbol.kr(1);
	}) + detune;

	var amps = (0..numFreqs-1).collect({arg i;
		(\a ++ i).asSymbol.kr(1/numFreqs);
	});

	var rings = (0..numFreqs-1).collect({arg i;
		(\r ++ i).asSymbol.kr(1);
	});

	var sig = DynKlank.ar(`[freq * ffreqs, amps, rings], in);

	sig * AmpCompA.kr(freq) * \amp.kr(0);
})

~lfo.def.sourceCode
~p[\env3].mold

~p[\env3] = ~tline.(dur:[0.01, 0.001], start:1, end:0);
~p[\env3].set(\trig, ~p[\trig1])

~p[\fl1] = ~tline.(dur:0.01, start:0.1, end:3.2);
~p[\rl1] = ~tline.(dur:0.1, start:1, end:0);
~p[\rl2] = ~tline.(dur:0.01, start:0, end:1);

~p[\rlfo] = ~lfo.(wave:\sin, freq:50, min:0, max:1)
~p[\flfo] = ~lfo.(wave:\sin, freq:50, min:2.0, max:4.0)
~p[\flfo] = ~lfo.(wave:\noise, freq:3, min:2.0, max: 4.0)

~p[\wn] = { WhiteNoise.ar * ~p[\env3]};

~p[\s2] <<> ~p[\wn];
(~p[\s2].set(\amp, 0.1,

	\freq, ~p[\freq],
	\vdepth, 0.001,
	\lag, 0.0012,

	\f0, 1.02340,
	\f1, ~p[\fl1],
	\f2, 5.234,
	\f3, 9.123,
	\f4, 11.23,
	\f5, 13.93930,

	\detune, 0.0,

	\r0, 1,
	\r1, 1/2,
	\r2, 1/3,
	\r3, 1/4,
	\r4, 1/5,
	\r5, 1/8

));
~p[\s2].gui
~p[\s2].vol = 0.5;
~p[\s2].stop

~p[\splay2] = ~splay.(chans:~p[\s2].numChannels);
~p[\splay2] <<> ~p[\s2];
~p[\splay2].play
~p[\splay2].stop
~p[\splay2].vol = 0.5;

~p[\dist2].mold
~p[\dist2] = ~waveloss.(chans:~p[\splay2].numChannels);
~p[\dist2] <<> ~p[\splay2]
~p[\dist2].play
~p[\dist2].stop
//~p[\dist2].unset(\drive);
~p[\dist2].gui;
~p[\dist2].vol = 1

~p[\rlpf] = ~rlpf.(chans: ~p[\dist2].numChannels);
~p[\rlpf] <<> ~p[\dist2];
~p[\rlpf].set(\freq, 4000, \rq, 0.4, \wet, 0);
~p[\rlpf].play
~p[\rlpf].vol = 0.2;

~p[\verb3] = ~jpverb.(chans:~p[\rlpf].numChannels);
~p[\verb3] <<> ~p[\splay2];
~p[\verb3].set(\wet, 0.2);
~p[\verb3].play;
~p[\verb3].vol = 0.4

~p[\delay2] = ~delayorama.(chans:~p[\splay2].numChannels);
~p[\delay2] <<> ~p[\splay2]
~p[\delay2].set(\wet, 0.5)
~p[\delay2].play
~p[\delay2].stop;
~p[\delay2].vol = 1
~p[\delay2].gui


~p[\s2].play


App.recordVersion
s.stopRecording