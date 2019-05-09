(
~p[\t2] = {

	var numvoices = 2;
	var detune = \detune.kr(0.01);
	var trig = \trig.tr;
	var freq = Vibrato.kr(
		\freq.kr(432).lag(\lag.kr(0.1)),
		\vrate.kr(6),
		\vdepth.kr(0.001)
	);

	var which = \which.kr(1);
	var focus = \focus.kr(0.5);
	var atk = \atk.kr(0.01);
	var decay = \dec.kr(1);
	var noise = SelectXFocus.kr(
		which,
		[BrownNoise.ar(1), PinkNoise.ar(1), WhiteNoise.ar(1)],
		focus,
		wrap:true);

	var sig = {
		var ex = Latch.ar(noise, trig);
		Formlet.ar(ex, freq * LFNoise2.kr(\ddepth.kr(5)).range(1 + detune.neg, 1 + detune), atk, decay);
	}.dup(numvoices) * Array.fill(numvoices,1).normalizeSum;

	sig = Limiter.ar(sig.sum, 0.8) * AmpCompA.kr(freq) * \amp.kr(-12.dbamp);
	sig = Pan2.ar(sig, \pan.kr(0));
	sig;
}
)

/////////////////////////////////////////
// t2 settings

Pdefn(\t2_mtranspose, -3);
Pdefn(\t2_root, 0);
Pdefn(\t2_scale, Scale.dorian);
Pdefn(\t2_dur, 0.25);
Pdefn(\t2_degrees, Pseq([0], inf));


/////////////////////////////////////////
// t2 base pattern
(
Pdef(\t2_base,
	Pbind(
		\type, \set,
		\id, Pfunc({arg evt; evt[\node].nodeID;}),
		\args, #[\trig, \freq, \amp],
		\trig, 1,
		\degrees, Pdefn(\t2_degrees),
		\foo, Pif(Pfunc({arg evt; evt[\seq].coin}), 1, Rest()),
		\degree, Pkey(\degrees) + Pkey(\offset),
		\scale, Pdefn(\t2_scale),
		\mtranspose, Pdefn(\t2_mtranspose),
		\root, Pdefn(\t2_root),
		\dur, Pdefn(\t2_dur),
		\amp, Pkey(\amp) * 5
	)
);
)

/////////////////////////////////////////
// t2
(
var envir = ~p.envir;

var patterns = [
	{
		var seq = Array.fill(96, {0})[0] = 1;
		var p = Pbind(
			\amp, -10.dbamp,
			\octave, 6,
			\seq, Pseq(seq, inf),
			\offset, Pseq([0,-2], inf)
		);

		var n = envir[\t2];

		(k:\t2_1, p:p, n:n);
	},

	{
		var seq = Array.fill(48, {0})[13] = 1;
		var p = Pbind(
			\amp, -16.dbamp,
			\octave, 7,
			\seq, Pseq(seq, inf),
			\offset, Pseq([2,3,1], inf)
		);

		var n = envir[\t2];

		(k:\t2_2, p:p, n:n);
	}

].collect({arg func, i;
	var obj = func.();
	var key = obj[\k];
	var pat = obj[\p];
	var node = obj[\n];
	if (node.isKindOf(Function)) {
		envir[key] = node;
		node = envir[key];
	};
	Pdef(\t2_base) <> Pbind(\node, Pfunc({node})) <> pat;
});

Pdef(\t2_main, {
	"init".debug(\t2_main);
	Ppar(patterns, inf);
});
)

/////////////////////////////////////////
// t2 play
~p[\t2].play;
~p[\t2].stop;
Pdef(\t2_main).play;
Pdef(\t2_main).stop;


(
~p[\t2_del] = {
	var in = ~p[\t2].ar;
	var fx = FbC({arg fb; fb * 0.5 + in}, [3/4, 4/4]);
	fx
};
)
~p[\t2_del].play;

~p[\t2_mix2][0] = \mix -> {~p[\t2].ar};
~p[\t2_mix2][1] = \mix -> {~p[\t2_del].ar};
~p[\t2_mix2][2] = \mix -> {~p[\t2_rev2].ar * 0.1;};

(
~p[\t2_rev] = {
	var in = \in.ar([0, 0]);
	var fx = JPverb.ar(in, 9, 0, 5);
	fx;
}
);
~p[\t2_rev].play(vol:1);
~p[\t2_rev] <<> ~p[\t2_mix2];

(
~p[\t2_del2] = {
	var in = \in.ar([0,0]);
	var fx = FbC({arg fb; fb * 0.2 + in}, 2 + [3/4, 4/4]);
	fx;
}
)
~p[\t2_del2].stop;
~p[\t2_del2] <<> ~p[\t2_rev];

(
~t2_ps1 = {
	var in = \in.ar([0,0]);
	var fx = PitchShift.ar(in, 0.5, 12.midiratio, 0.01, 0.01) * 0.89;
	fx
}
)
~t2_ps1 <<> ~t2_del2;

(
~t2_del3 = {
	var in = \in.ar([0,0]);
	var fx = FbC({arg fb; fb * 0.2 + in}, 3 + [3/4, 4/4]);
	fx;
};
)
~t2_del3 <<> ~t2_rev;

(
~t2_ps2 = {
	var in = \in.ar([0,0]);
	var fx = PitchShift.ar(in, 0.5, 7.midiratio, 0.01, 0.01) * 0.89;
	fx
};
)
~t2_ps2 <<> ~t2_del3;

(
~t2_rev2 = {
	var in = \in.ar([0,0]);
	var fx = JPverb.ar(in, 7, 0, 5, modDepth:0.8);
	fx;
};
)
~t2_rev2 <<> ~t2_mix3

~t2_mix3[0] = \mix -> {~t2_ps1.ar};
~t2_mix3[1] = \mix -> {~t2_ps2.ar};

(
~t2_squiz = {
	var in = \in.ar([0,0]);
	var fx = Squiz.ar(in.reverse, [7.midiratio, 12.midiratio], LFNoise2.kr(1/4).range(2, 30));
	Rotate2.ar(fx[0], fx[1], LFTri.kr(1/4));
}
)
~t2_squiz.play(vol:0.2);
~t2_squiz <<> ~t2_mix3;

s.record
s.stopRecording


