~p = ProxySpace.new(s);
~p.quant = 1.0;


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
//~p[\trig1].clear;
~p[\trig1] = {~p[\seq1].kr[0]}

/////////////////////////////////
// freq
//~p[\freq].clear;
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
//~tlinen.argNames
//~tlinen.def.sourceCode
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
//~fm7.def.sourceCode
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
~p[\ps].play
~p[\ps].stop

~p[\gverb] = ~gverb.(roomsize:50);
~p[\gverb] <<> ~p[\ps];//~p[\dist];
~p[\gverb].play
~p[\gverb].stop;
~p[\gverb].vol = 0.15


~h = ~ps_helper.(~p);
~h.ls_monitor();


App.recordVersion
s.stopRecording