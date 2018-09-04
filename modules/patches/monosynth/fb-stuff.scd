(
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(1);
~p.makeTempoClock;
)


/////////////////////////////////////////
// seq1
~p[\seq1].clear;
(~p[\seq1][0] = {
	var freq = \freq.kr;
	var trig = \trig.tr;
	[freq, trig];
});
(~p[\seq1][1] = \set -> Pbind(
	\trig, 1,
	\delta, Pseq([
		1, 3
	], inf) * 0.5,
	\degree, Pseq([
		-2, -2,
		0, 0,
		2, 2,
		5, 5
	], inf),
	\octave, 6
))

/////////////////////////////////////////
// s1
~p[\s1].clear;
~p[\s1].mold;
(~p[\s1][0] = {
    var seq = ~p[\seq1].kr;
	var freq = seq[0];
	var trig = seq[1];
	var sig = SinOsc.ar(freq);
	var env = Env.perc(releaseTime:0.5).kr(gate:trig);
	Pan2.ar(sig) * env;
});
~p[\s1].play(out:0, vol:1);
~p[\s1].stop;
~p[\s1].gui;


/////////////////////////////////////////
// s2
~p[\s2].clear;
~p[\s2].mold;
(~p[\s2][0] = {
    var seq = ~p[\seq1].kr;
	var freq = seq[0];
	var trig = seq[1];
	var mytrig = PulseDivider.kr(trig, 3);

	var sig = VarSaw.ar(freq * 2);
	var env = Decay2.kr(mytrig, decayTime:0.5);

	Pan2.ar(sig) * env;
});
~p[\s2].play(out:2);
~p[\s2].stop;
~p[\s2].gui;


/////////////////////////////////////////
// fb1
~p[\fb1].clear;
(
~p[\fb1][0] = {

	var in = Mix(~p[\s2].ar);
	var delay = \delay.kr(3/4);
	var trig2;
	var fbNode = FbNode(1, 6.5, 4);
	var sig = fbNode.delay(delay) * \fb.kr(0.6);
	fbNode.write(sig + in);
	sig = DiodeRingMod.ar(sig, SinOsc.ar(220));
	Pan2.ar(sig, \pan.kr(-0.7));
};
);
~p[\fb1].play(out:4);
~p[\fb1].stop;


/////////////////////////////////////////
// fx1
~p[\fx1].clear;
(~p[\fx1][0] = {

	var in = ~p[\fb1].ar;
	var seq = ~p[\seq1].kr;
	var freq = seq[0];

	var trig = PulseDivider.kr(Trig1.kr(in, 1), 4);
	var sig = PMOsc.ar(freq * 0.5, freq * 2, 3);
	var env = Decay2.kr(trig, decayTime:0.2);
	Pan2.ar(sig) * env;
});
~p[\fx1].play(out:6);
~p[\fx1].stop;
~p[\fx1].gui;

/////////////////////////////////////////
// fb2
~p[\fb2].clear;
(
~p[\fb2][0] = {

	var in = Mix(~p[\fx1].ar);
	var delay = \delay.kr(7/16);
	var trig2;
	var fbNode = FbNode(2, 6.5, 4);
	var sig = [Mix(fbNode.delay(delay)), Mix(fbNode.delay(9/16))] * \fb.kr(0.3);
	fbNode.write(sig + in);
	Squiz.ar(FreqShift.ar(sig, 2200));
};
);
~p[\fb2].play(out:8);
~p[\fb2].stop;

App.recordWorkspace("ws1");
s.stopRecording