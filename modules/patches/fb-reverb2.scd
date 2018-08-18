/////////////////////////////////////////
// proxy space
(
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 1.0;
~p.fadeTime = 2;
)

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
	\delta, Pseq([3, 3, 2], inf) * 0.125,
	\octave, Pseq([
		6, 5, 5, 5,
		5, 5, 6, 5,
		6, 5, 5, 5,
		5, 6, 5, 5
	], inf),
	\scale, Scale.dorian,
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

	var width = \width.kr(0.3);
	var sig = VarSaw.ar(freq, width:width);
	sig = sig + (Pulse.ar(freq, width:width) * 0.3);
	sig = sig * Decay2.kr(trig, 0.01, decayTime:0.3);
	Splay.ar(sig) * 0.5;
};
~p[\s1][1] = {

	var seq = ~p[\seq].kr;
	var freq = seq[0];
	var trig = \trig.tr;

	var start = 3;//LFTri.kr(1/32).range(3, 6);
	var index = Env([start,start,0],[0, 1],0).kr(gate:trig);
	var sig = PMOsc.ar(freq, freq * 2.01, index);
	sig = sig * Decay2.kr(trig, 0.01, decayTime:0.1);
	Splay.ar(sig) * 0.05;
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
// s2
(
~p[\s2][0] = {

	var seq = ~p[\seq].kr;
	var freq = seq[0];
	var trig = seq[1];
	var sig = SinOscFB.ar(freq * 0.5, 0.7);
	trig = PulseDivider.kr(trig, 3);
	sig = sig * Env.linen(sustainTime:3).kr(gate:trig);
	Splay.ar(sig) * 0.1;
};
);

/////////////////////////////////////////
// fb1
(
~p[\fb1][0] = {

	var in = Mix(~p[\s1].ar);
	var delay = \delay.kr(3/4);
	var fbNode = FbNode(1, 6.5, 4);
	var sig = fbNode.delay(delay) * \fb.kr(0.4);
	fbNode.write(sig + in);
	sig = RLPF.ar(sig, 1880, 0.2);
	Pan2.ar(sig, \pan.kr(0));
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
	Pan2.ar(sig, \pan.kr(0.5));
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
	sig = (sig * 2.1).tanh;
	fbNode.write(sig + in);
	Splay.ar(sig);
};
)
~p[\fb3].play;
~p[\fb3].stop;

/////////////////////////////////////////
// fb4
(
~p[\fb4][0] = {

	var in = Mix(~p[\s2].ar);
	var delay = \delay.kr(2.3);
	var fbNode = FbNode(1, 6.5, 4);
	var sig = fbNode.delay(delay) * \fb.kr(0.5);
	sig = LeakDC.ar(sig.abs);
	fbNode.write(sig + in);
	sig = GVerb.ar(sig, 100, revtime:60);
	sig = (sig * 0.5) + (sig * LFPulse.kr(SinOsc.kr(1/16).range(1/16, 5)));
	sig * 0.5
};
)

/////////////////////////////////////////
// buf
(
~p[\buf][0] = {

	var in = ~p[\fb2].ar;

	var buf = LocalBuf(s.sampleRate * 10, 1).clear;

	var foo = {
		var rec = \rec.kr(1);
		var renv = Env.asr.kr(gate:rec);
		var penv = Env.asr.kr(gate:rec) * \plevel.kr(0);
		RecordBuf.ar(Mix.ar(in),
			buf,
			recLevel:renv,
			preLevel:penv,
			run:rec,
			loop:\rec_loop.kr(0),
			trigger:\rec_trig.kr(1)
		);
	}.();

	var pos = \pos.kr(0) * BufFrames.kr(buf);
	var trig = \trig.tr;
	var loop = \loop.kr(1);
	var sig = PlayBufCF.ar(1, buf, rate:\rate.kr(-0.5), trigger:trig, startPos:pos, loop:loop);
	Pan2.ar(sig, \pan.kr(0));
};
);

/////////////////////////////////////////
// mix1
(
~p[\mix1][0] = \mix -> {~p[\s1]};
~p[\mix1][1] = \mix -> {~p[\fb1]};
~p[\mix1][2] = \mix -> {~p[\fb2]};
~p[\mix1][3] = \mix -> {~p[\fb3]};
~p[\mix1][4] = \mix -> {~p[\s2]};
~p[\mix1][5] = \mix -> {~p[\fb4]};
~p[\mix1][6] = \mix -> {~p[\buf]};
~p[\mix1].set(\mix0, 0, \mix1, 0, \mix2, 0, \mix3, 0, \mix4, 0, \mix5, 1, \mix6, 0);
~p[\mix1].addSpec(\mix0, [0, 1, \lin, 0, 0]);
~p[\mix1].addSpec(\mix1, [0, 1, \lin, 0, 0]);
~p[\mix1].addSpec(\mix2, [0, 1, \lin, 0, 0]);
~p[\mix1].addSpec(\mix3, [0, 1, \lin, 0, 0]);
~p[\mix1].addSpec(\mix4, [0, 1, \lin, 0, 1]);
~p[\mix1].addSpec(\mix5, [0, 1, \lin, 0, 0]);
~p[\mix1].addSpec(\mix6, [0, 1, \lin, 0, 0]);
)

/////////////////////////////////////////
// verb
(
~p[\verb][0] = {
	var in = ~p[\mix1].ar;
	var fx = JPverb.ar(in, 5, 0, 5, modDepth:0.8);
	fx
};
);

/////////////////////////////////////////
// play
(
~p[\verb].play(fadeTime:5, vol:0.4);
~p[\mix1].play(fadeTime:2);
~p[\mix1].gui().alwaysOnTop_(true)
)

/////////////////////////////////////////
// preset 0
(
~p[\mix1].set(\mix0, 0, \mix1, 0, \mix2, 0, \mix3, 0, \mix4, 0, \mix5, 1, \mix6, 0);
~p[\mix1].vol = 0.1;
~p[\verb].vol = 0.1;
)

/////////////////////////////////////////
// preset 1
(
~p[\mix1].set(\mix0, 0.58,
	\mix1, 0.7,
	\mix2, 0.51,
	\mix3, 0.41,
	\mix4, 0.64,
	\mix5, 0.35,
	\mix6, 0.39
);
~p[\mix1].vol = 0.1;
~p[\verb].vol = 0.1;
)

/////////////////////////////////////////
// preset 2
~p[\mix1].vol = 0;
~p[\verb].vol = 0.1;


s.meter(2,2).window.alwaysOnTop_(true);

App.recordWorkspace("ws14");
s.stopRecording



(
var v1, v2, view2;
var view = Window();
view.addFlowLayout();

NdefGui(~p[\mix1], parent:view);
NdefGui(~p[\verb], parent:view);

view2 = View().layout_(VLayout()).minHeight_(200).minWidth_(500);
view2.layout.add(view.asView);
view2.front;
)

(
w = Window().front;
w.addFlowLayout;
n = NdefGui(Ndef(\a), 4, w, options: NdefGui.big);
)



Event