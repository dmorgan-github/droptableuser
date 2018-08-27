/////////////////////////////////////////
// proxy space
~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 4.0;
~p.fadeTime = 2;
~p.clock = TempoClock.default.tempo_(60/60);

/////////////////////////////////////////
// seq
~p[\seq]
(~p[\seq][0] = {
    var freq = \freq.kr;
	var trig = \trig.tr;
	[freq, trig];
});
(~p[\seq][1] = \set -> Pbind(
	\trig, 1,
	\delta, 1
))


/////////////////////////////////////////
// n1
~p[\n1].clear;
~p[\n1].mold;
(~p[\n1][0] = {

	var freq = 440;
	var seq = ~p[\seq].kr;
	var trig = seq[1];

	var sig = Pluck.ar(WhiteNoise.ar, Impulse.kr(1),
		freq.reciprocal * 2,
		freq.reciprocal * 2,
		10,
		0.3
	);

	Pan2.ar(sig, \pan.kr(0));
});
~p[\n1].play(vol:0.2);
~p[\n1].stop(fadeTime:5);
~p[\n1].gui;

App.recordWorkspace("ws12");
s.stopRecording
