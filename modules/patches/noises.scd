
/////////////////////////////////////////
// n1
~p[\n1].clear;
~p[\n1].mold;
(~p[\n1][0] = {

    var trig = \trig.tr;
	var sig = WhiteNoise.ar;
	var env = Decay2.kr(trig, decayTime:0.1);
	sig = sig * env * \amp.kr(-10.dbamp);

	sig = RLPF.ar(sig, Env([3200,3200,1200],[0,0.1],-4).kr(gate:trig), 0.5);

	sig = sig + FbC({arg fb; fb * 0.7 + sig}, 0.1);

	Splay.ar(sig);

});
~p[\n1].play(vol:5);

~p[\n1].set(\trig, 1);

~p[\n1].stop;
~p[\n1].gui;


/////////////////////////////////////////
// n1
~p[\n2].clear;
~p[\n2].mold;
(~p[\n2][0] = {

    var trig = \trig.tr;
	var sig = WhiteNoise.ar;
	var env = Decay2.kr(trig, decayTime:5);
	sig = sig * env * \amp.kr(-10.dbamp);

	sig = RLPF.ar(sig, Env([3200,3200,1200],[0,5],-4).kr(gate:trig), 0.01);

	sig = sig + FbC({arg fb; fb * 0.7 + sig}, 0.1);

	Splay.ar(sig);

});
~p[\n2].play;
~p[\n2].set(\trig, 1);
~p[\n2].stop;
~p[\n2].gui;


/////////////////////////////////////////
// n3
~p[\n3].clear;
~p[\n3].mold;
(~p[\n3][0] = {

    var trig = \trig.tr;
	var sig = WhiteNoise.ar;
	var env = Decay2.kr(trig, decayTime:0.1);
	sig = sig * env * \amp.kr(-10.dbamp);

	sig = RLPF.ar(sig, Env([3200,3200,1200],[0,0.1],-4).kr(gate:trig), 0.05);

	sig = sig + FbC({arg fb; fb * 0.7 + sig}, 0.1);

	Splay.ar(sig);

});
~p[\n3].play(vol:5);

(~p[\n3][2] = \set -> Pbind(
	\trig, 1,
	\dur, Pseq([3, [3,2,1,2,3] ].convertRhythm, 1) * 0.5
));

~p[\n3].set(\trig, 1);

~p[\n3].stop;
~p[\n3].gui;


App.recordWorkspace("ws8");
s.stopRecording