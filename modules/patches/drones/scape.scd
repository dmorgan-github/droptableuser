~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 1.0;
~p.fadeTime = 1;
~p.makeTempoClock;

/////////////////////////////////////////
// seq
(~p[\seq][0] = {
	var trig = Dust.kr(0.5);
	var freq = Demand.kr(trig, 0, Drand(Scale.dorian.degrees + 92, inf));
	[freq.midicps, trig];
});

/////////////////////////////////////////
// s1
(~p[\s1][0] = {
	var freq = ~p[\seq].kr[0];
	var trig = ~p[\seq].kr[1];
	SinOsc.ar(freq, 0, 4).tanh * Decay2.kr(trig, decayTime:0.05) * \amp.kr(0.2);
});
~p[\s1].play;
~p[\s1].stop;
~p[\s1].gui;

/////////////////////////////////////////
// s2
(~p[\s2][0] = {
    var freq = ~p[\seq].kr[0];
	var trig = ~p[\seq].kr[1];
	trig = PulseDivider.kr(trig, 8);
	freq = Latch.kr(freq, trig);
	VarSaw.ar(freq/2) * Decay2.kr(trig, decayTime:1) * \amp.kr(0.1);
});
~p[\s2].play;
~p[\s2].stop;
~p[\s2].gui;

/////////////////////////////////////////
// mix1
~p[\mix1][0] = \mix -> {~p[\s1]};
~p[\mix1][1] = \mix -> {~p[\s2]};
~p[\mix1].play;
~p[\mix1].stop;
~p[\mix1].gui;
~p[\mix1].set(\mix0, 1, \mix1, 0.8);

/////////////////////////////////////////
// del
(~p[\del][0] = {
	var in = \in.ar([0]);
	var fx = Mix.ar({
		var sig = PitchShift.ar(in, rrand(0.1, 0.5), pitchRatio:rrand(0.5,4));
		CombC.ar(sig, 4, rrand(0.1,4.0), rrand(1,10))
	}.dup(10));
	Splay.ar(fx);
});
~p[\del] <<> ~p[\mix1];
~p[\del].play;
~p[\del].stop;
~p[\del].gui;

/////////////////////////////////////////
// reverb
(~p[\reverb][0] = {
	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in,
		\t60.kr(1),
		\damp.kr(0),
		\size.kr(1),
		\earlyDiff.kr(0.707),
		\modDepth.kr(0.1),
		\modFreq.kr(2)
	);
	fx;
});
~p[\reverb] <<> ~p[\del];
~p[\reverb].play;
~p[\reverb].stop;
~p[\reverb].gui;

/////////////////////////////////////////
// mix2
~p[\mix2][0] = \mix -> {~p[\s1]};
~p[\mix2][1] = \mix -> {~p[\s2]};
~p[\mix2].play;
~p[\mix2].stop;
~p[\mix2].gui;
~p[\mix2].set(\mix0, 1, \mix1, 1);

/////////////////////////////////////////
// dist
(~p[\dist][0] = {
	var in = \in.ar([0]);
	var fx = SoftClipAmp8.ar(in, \pregain.kr(1));
	Splay.ar(fx);
});
~p[\dist] <<> ~p[\mix2];
~p[\dist].play;
~p[\dist].stop;
~p[\dist].gui;

/////////////////////////////////////////
// grey
(~p[\grey][0] = {
	var in = Mix.ar(~p[\dist]);
	var fx = Greyhole.ar(in, 5, size: 5, modDepth:\modDepth.kr(0.7));
	fx = LPF.ar(fx, 2000);
	fx;
});
~p[\grey].play;
~p[\grey].stop;
~p[\grey].gui;

/////////////////////////////////////////
// filt
(~p[\filt][0] = {
	var in = ~p[\grey];
	var fx = MoogVCF.ar(in, SinOsc.kr(1).range(880, 2000), 0.2);
	fx;
});
~p[\filt].play;
~p[\filt].stop;
~p[\filt].gui;


/////////////////////////////////////////
// rotate
(~p[\rotate][0] = {
	var in = ~p[\grey].ar;
	var fx = Rotate2.ar(in[0], in[1], SinOsc.kr(1/16).range(-1, 1));
	fx;
});
~p[\rotate].vol = 0.8;
~p[\rotate].play;
~p[\rotate].stop;
~p[\rotate].gui;


/////////////////////////////////////////
// verb2
(~p[\verb2][0] = {
	var in = ~p[\rotate];
	var fx = JPverb.ar(in + PitchShift.ar(in, 0.1, 0.5, mul:0.8),
		\t60.kr(1),
		\damp.kr(0),
		\size.kr(1),
		\earlyDiff.kr(0.707),
		\modDepth.kr(0.1),
		\modFreq.kr(2)
	);
	fx;
});
~p[\verb2].set(\t60, 3, \size, 5)
~p[\verb2].play;
~p[\verb2].stop;
~p[\verb2].gui;

App.recordWorkspace("ws14");
s.stopRecording

BlackRain

s.meter(2,2).window.alwaysOnTop_(true);

~p[\verb2].bus


/////////////////////////////////////////
// s3
(~p[\s3][0] = {

	var fbNode = FbNode(2, 10);
	var fb = fbNode.delay(1);

	var sig = SinOsc.ar + fb;
	Out.ar(16, sig);
	sig = sig + In.ar(18, 2);

	fbNode.write(sig);

});
~p[\s3].play;
~p[\s3].stop;
~p[\s3].gui;


// private, reusable
(Fdef(\fb, {arg sig;

	sig;
}))

/////////////////////////////////////////
// test2
(~p[\test2][0] = {
	var fbNode = FbNode();
    var sig = fbNode.delay(0.1);
	sig = Fdef(\fb).value(sig);
	fbNode.write(sig);
	sig;
});
~p[\test2].play;
~p[\test2].stop;
~p[\test2].gui;

/////////////////////////////////////////
// test
// shared, reusable
(~p[\test][0] = {

	var in = In.ar(16, 2);
	Out.ar(18, Silent.ar);

});
~p[\test].play;
~p[\test].stop;
~p[\test].gui;
