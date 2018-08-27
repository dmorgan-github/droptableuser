/////////////////////////////////////////
// proxy space
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(1);



/////////////////////////////////////////
// sequencer
(
~p[\seq][0] = {
	var freq = \freq.kr;
	var trig = \trig.tr;
	[freq, trig];
};
~p[\seq][2] = \set -> Pbind(
	\trig, 1,
	\delta, Pseq([3, 3, 2], inf) * Pdefn(\dur, 0.125),
	\octave, Pseq([
		6, 5, 5, 5,
		5, 5, 6, 5,
		6, 5, 5, 5,
		5, 6, 5, 5
	], inf),
	\scale, Scale.augmented,
	\degree, Pseq([
		0, -3, -2,
		3, 0, 1,
	], inf)
);
);

/////////////////////////////////////////
// s1
(
~p[\s1][0] = {
	var seq = ~p[\seq].kr;
	var freq = seq[0];
	var trig = seq[1];
	var decay = \decay1.kr(0.3);

	var width = \width.kr(0.3);
	var sig = VarSaw.ar(freq, width:width);
	sig = sig + (Pulse.ar(freq, width:width) * 0.2);
	sig = sig * Decay2.kr(trig, 0.001, decayTime:decay);
	Pan2.ar(sig, 0.4) * \mix1.kr(0.6);
};
~p[\s1][1] = {

	var seq = ~p[\seq].kr;
	var freq = seq[0];
	var trig = \trig.tr;
	var decay = \decay2.kr(0.2);

	var start = \start.kr(3);
	var index = Env([start,start,0],[0, decay],0).kr(gate:trig);
	var sig = PMOsc.ar(freq, freq * 2.01, index);
	sig = sig * Decay2.kr(trig, 0.001, decayTime:decay);
	Pan2.ar(sig, -0.4) * \mix2.kr(0.1);
};
~p[\s1][4] = \set -> Pbind(
	\args, #[\trig],
	\trig, Pbjorklund2(3, 7, inf),
	\delta, 0.5
);
~p[\s1][6] = \set -> Pbind(
	\args, #[\width],
	\width, Pbjorklund2(3, 7, inf).collect({arg val; if (val == 0) {0.3}{0.7}}),
	\delta, 0.25
)
)
~p[\s1].play;
~p[\s1].stop;


/////////////////////////////////////////
// fb1
(
~p[\fb1][0] = {

	var in = Mix(~p[\s1].ar);
	var delay = \delay.kr(3/4);
	var fbNode = FbNode(1, 6.5, 4);
	var sig = fbNode.delay(delay) * \fb.kr(0.4);
	fbNode.write(in);
	sig = RLPF.ar(sig, 1880, 0.2);
	Pan2.ar(sig, \pan.kr(-0.7));
};
);
~p[\fb1].play;
~p[\fb1].stop;

/////////////////////////////////////////
// fb2
(
~p[\fb2][0] = {

	var in = Mix(~p[\s1].ar);
	var delay = \delay.kr(4/4);
	var fbNode = FbNode(1, 6.5, 4);
	var sig = fbNode.delay(delay) * \fb.kr(0.7);
	fbNode.write(sig + in);
	sig = LeakDC.ar(sig.abs);
	Pan2.ar(sig, \pan.kr(0.7));
};
)
~p[\fb2].play;
~p[\fb2].stop;

/////////////////////////////////////////
// fb3
(
~p[\fb3][0] = {

	var in = Mix.ar(~p[\s1].ar);
	var delay = \delay.kr(5/4);
	var fbNode = FbNode(1, 6.5, 4);
	var sig = fbNode.delay(delay) * \fb.kr(0.4);
	fbNode.write(in);
	sig = (sig * 3.1).tanh;
	Splay.ar(sig);
};
)
~p[\fb3].play;
~p[\fb3].stop;

/////////////////////////////////////////
// play
~p[\s1].play(out:0);
~p[\fb1].play(out:0);
~p[\fb2].play(out:0);
~p[\fb3].play(out:0);

~p[\s1].stop(fadeTime:5);
~p[\fb1].stop(fadeTime:5);
~p[\fb2].stop(fadeTime:5);
~p[\fb3].stop(fadeTime:5);

/////////////////////////////////////////
// scene 1
(
~p[\s1].set(\decay1, 0.3, \decay2, 0.3);
~p[\s1].set(\start, 3);
~p[\s1].set(\mix1, 0.6, \mix2, 0.1);
Pdefn(\dur, 0.125);
)

/////////////////////////////////////////
// scene 2
(
~p[\s1].set(\decay1, 0.1, \decay2, 0.1);
~p[\s1].set(\mix1, 0.6, \mix2, 0.1);
Pdefn(\dur, 1);
)




/////////////////////////////////////////
// mix1
(
~p[\mix1][0] = \mix -> {~p[\s1]};
~p[\mix1][1] = \mix -> {~p[\fb1]};
~p[\mix1][2] = \mix -> {~p[\fb2]};
~p[\mix1][3] = \mix -> {~p[\fb3]};
~p[\mix1].addSpec(\mix0, [0, 1, \lin, 0, 0]);
~p[\mix1].addSpec(\mix1, [0, 1, \lin, 0, 0]);
~p[\mix1].addSpec(\mix2, [0, 1, \lin, 0, 0]);
~p[\mix1].addSpec(\mix3, [0, 1, \lin, 0, 0]);
~p[\mix1].set(\mix0, 1, \mix1, 0.92, \mix2, 0.49, \mix3, 0.58);
)
~p[\mix1].play;


/////////////////////////////////////////
// verb
(
~p[\verb][0] = {
	var in = ~p[\mix1].ar;
	JPverb.ar(in, 5, 0, 5, modDepth:0.5);
};
);
~p[\verb].stop;


App.saveWorkspace
s.meter(2,2).window.alwaysOnTop_(true);


