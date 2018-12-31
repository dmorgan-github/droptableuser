
(~p[\snd][0] = {

	var trig = \trig.tr;
	var rel = 8;
	var env = Env.perc(releaseTime:rel, curve:-4).kr(gate:trig);
	var in = GrainFM.ar(1,
		Impulse.kr(8),
		dur:SinOsc.kr(2).range(0.01, 0.1),
		carfreq: 880,
		modfreq: Env([660,660,30],[0,rel],-4).kr(gate:trig),
		index:Env([6,6,0.1],[0,rel],-4).kr(gate:trig)
	);

	var sig = FbC({arg fb;
		var sig = fb + in;
		sig = FreqShift.ar(sig, [-500, 500]);
		sig = SoftClipper8.ar(sig, 1.5);
		sig;
	}, 0.1);
	sig = sig * env;
	Splay.ar(sig) * \amp.kr(-12.dbamp);
})
~p[\snd][2] = \set -> Pbind(\trig, 1, \dur, 8);
~p[\snd].play;
~p[\snd].stop;