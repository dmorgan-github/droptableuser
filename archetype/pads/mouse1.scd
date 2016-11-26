(
ProxySynthDef(\mouse1, {

	var trig = \trig.kr;
	var env = EnvGen.kr(Env([0,0,1,0],
		[1e-6, \atk.kr(0.6), \rel.kr(1) - \atk.kr],
		curve: \curve.kr(-4)
	), gate: trig, timeScale: \dur.kr(1));

	var divs = fib(9);
	var sig = SinOscFB.ar(
		SinOscFB.ar(
			SinOscFB.ar(99/divs, 1),
			1/divs
		) + divs * MouseX.kr(10, 50),
		1
	);

	sig = mean(
		FreqShift.ar(
			sig,
			1/divs
		) + sig
	);
	sig = GVerb.ar(sig,200,3,0.5,0.5,9,1,0.7,1);
	sig * env * 0.1;

}).add;
)
///////////////////////////////////////////
~mouse1 = App.monoDevice(\mouse1);
(~mouse1.pattern.set(
	\trig, Pseq([1, 0], inf),
	\dur, 16
));
(~mouse1.node[10] = \filter -> {arg in;

	var sig1 = FbC({arg fb; in + (fb.reverse * 0.4 ); }, 0.375 );
	var sig2 = FbC({arg fb; in + (fb.reverse * 0.4 ); }, 0.25 );
	var sig3 = XFade2.ar(sig1, sig2, HenonC.ar([0.375, 0.5]).range(-1, 1), );

	var fbNode1 = FbNode(2, 1);
	var fx1 = sig3 + fbNode1.delay(0.25) * 0.7;
	fbNode1.write(fx1);
	FreeVerb.ar( in + sig3 + fx1 );
});
~mouse1.player.stop;
~mouse1.player.play;