~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 1.0;
~p.fadeTime = 5;
~p.makeTempoClock;


/////////////////////////////////////////
// seq
(~p[\seq][0] = {

	var freq = \freq.kr;
	var trig = \trig.tr;
	[freq, trig];
});
/////////////////////////////////////////
// seq
(~p[\seq][2] = \set -> Pbind(
	\trig, 1,
	\delta, 4,
	\octave, 5,
	\scale, Scale.dorian,
	\degree, Ppoisson(Pstutter(16, Pseq([1,2,3], inf)))//+ Prand([0,-7,7], inf),
));


/////////////////////////////////////////
// s1
(~p[\s1][0] = {
	var seq = ~p[\seq].kr;
	var freq = seq[0];
	var trig = seq[1];

	var lfo = SinOsc.kr(1/16).range(0.5, 2);
	var sig = VarSaw.ar(freq, 0, [0.3, 0.7]).sum;
	sig * Decay2.kr(trig, 1, decayTime:2);
});
~p[\s1].set(\decay, 0.1)
~p[\s1].play;
~p[\s1].stop;
~p[\s1].gui;

/////////////////////////////////////////
// s2
~p[\s2].mold;
(~p[\s2][0] = {

	var in = \in.ar([0]);
	var sig = in;

	var fbNode = FbNode(2, 10);
	var fb = fbNode.delay(\delay.kr(0.1, 0.1));
	sig = JPverb.ar(fb * 0.7 + sig, 10, 0, 5, modDepth:0.5);
	sig = SoftClipAmp8.ar(sig, SinOsc.kr(1/8).range(1, 1.3));
	sig = RLPF.ar(sig, SinOsc.kr([1/2, 1/4]).range(880, 3200), 1);
	sig = Splay.ar([sig[1], sig[0]]);
	fbNode.write(sig);

	sig * 0.3
});

(
~p[\s2].set(
	\decay, 0.7, \delay, 0.3,
);
)

~p[\s2] <<> ~p[\s1];
~p[\s2].play;
~p[\s2].stop;
~p[\s2].gui;

/////////////////////////////////////////
// verb
~p[\verb].clear;
~p[\verb].mold;
(~p[\verb][0] = {
	var in = ~p[\s2].ar;
	var fx = JPverb.ar(LPF.ar(in, 2200), 5, 0, 5, modDepth:0.8);
	fx
});
~p[\verb].play(vol:0.6);
~p[\verb].stop;
~p[\verb].gui;


s.meter(2,2).window.alwaysOnTop_(true);
