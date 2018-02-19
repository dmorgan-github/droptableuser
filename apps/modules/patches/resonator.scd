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
	\scale, Scale.ritusen,
	\degree, Ppatlace([Pseq([0,6], inf), Pseq([2,3,5,4], inf)], inf),
	\ctranspose, Pstep(Pseq([0, -5, 2, -7], inf), Pseq([4,4,4,4] * 4, inf), inf),
	\octave, 4,
	\delta, 0.125,
	\isRest, false,//Pwrand([true, false], [0.2,0.8], inf)
));


/////////////////////////////////
// trig
~p[\trig1].clear;
~p[\trig1] = {~p[\seq1].kr[0]}

/////////////////////////////////
// freq
~p[\freq].clear;
~p[\freq] = {~p[\seq1].kr[1]};

~h = ~ps_helper.(~p);
~h.ls_monitor();

~p[\env3] = ~tline.(dur:[0.01, 0.01], start:1, end:0);
~p[\env3].set(\trig, ~p[\trig1]);

~p[\wn] = { WhiteNoise.ar * ~p[\env3]};
~p[\wn].mold;

/////////////////////////////////////////////////////////
//

~p[\s2] = ~resN.(chans:~p[\wn].numChannels);
~p[\s2] <<> ~p[\wn];

~p[\fl1] = ~tline.(dur:0.01, start:0.1, end:3.2);

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

~p[\verb3] = ~jpverb.(chans:~p[\splay2].numChannels);
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