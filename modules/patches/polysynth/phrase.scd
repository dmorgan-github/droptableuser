(
SynthDef(\s1, {

	var freq = \freq.kr(432);
	var sig = SinOsc.ar(freq);
	var env = Env.adsr.kr(gate:\gate.kr(1), doneAction:Done.freeSelf);
	sig = sig * env * AmpCompA.kr(freq) * \amp.kr(-3.dbamp);
	sig = Splay.ar(sig);
	Out.ar(\out.kr(0), sig);

}).add;
)

(
Pdef(\s1, Pbind(
	\instrument, \s1,

	[\degree, \dur], Ptuple([
		Pseq([

			Pseq([0,1,2,3,4], 1),
			Pseq([
				[0,3,7],
				[2,5,9]
			], 1)

		], inf),
		Pseq([0.5, 1], inf)
	], inf),

	\amp, -0.3.dbamp
))
)

/////////////////////////////////////////
// phrase
~p[\phrase].clear;
~p[\phrase].mold;
~p[\phrase][0] = Pdef(\s1);

~p[\phrase].play(vol:0.25);
~p[\phrase].stop(fadeTime:10);
~phrase_win = App.guiHelper(~p[\phrase], "phrase");
~phrase_win.front;

(~p[\phrase].filter(2, {arg in;

	var sig = XFade2.ar( (in * 4).tanh, in, -0);
	sig = PinkNoise.ar * 0.1 + sig;
	sig = JPverb.ar(sig, 10, 0, 4) + sig;
	sig = LPF.ar( LPF.ar(sig, 2000), 2000);
	sig = JPverb.ar(sig, 3, 0, 3) + sig;
	sig;

}))


App.saveWorkspace("ws14", rec:true);