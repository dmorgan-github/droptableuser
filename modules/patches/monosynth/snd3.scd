
~p[\snd3].clear;
(~p[\snd3][0] = {

	var trig = \trig.tr;
	var rel = 2;
	var env = Env.perc(releaseTime:rel, curve:-4).kr(gate:trig);
	var in = SinOsc.ar(Env([5200,5200,220],[0,rel],-4).kr(gate:trig));

	var sig = FbC({arg fb;
		var sig = fb + in;
		sig = PitchShift.ar(sig, 0.5, 12.midiratio);
		sig = SoftClipper8.ar(sig, 3);
		sig = JPverb.ar(sig, 10, 0, 5) + sig;
		sig;
	}, 0.01);
	sig = sig * env;
	Splay.ar(sig) * \amp.kr(-12.dbamp);
})
~p[\snd3][2] = \set -> Pbind(\trig, 1, \dur, 4);
~p[\snd3].play;
~p[\snd3].stop;