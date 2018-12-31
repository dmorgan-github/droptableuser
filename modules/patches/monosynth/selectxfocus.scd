~p.push

~s1.mold;
~s1.clear;
(
~s1 = {

	var trig = \trig.tr;
	var lag = \lag.kr(0.02);
	var freq = Vibrato.kr(\freq.kr(110).lag(lag), \vrate.kr(6), \vdepth.kr(0.008));
	var detune = \detune.kr(2);

	var osc1 = {
		var det = LFNoise2.kr(1/8).range(detune.neg, detune);
		var width = \width.kr(0.5);
		var sig = VarSaw.ar(freq + det, 0, width) * 0.5;
		sig = RLPF.ar(sig, SinOsc.kr(1/4).range(880, 2200), SinOsc.kr(rrand(1/10, 1/8)).range(0.4, 0.7));
		sig;
	};

	var osc2 = {
		var freq_ratio = \osc2_freqratio.kr(1.5);
		var car_freq = freq * freq_ratio + LFNoise2.kr(1/8).range(detune.neg, detune);
		var	mod_ratio = \oc2_modratio.kr(1.01);
		var mod_index = car_freq * mod_ratio * Env([0, 3, 0.01], [0.5, 1], -4).kr(gate:trig, timeScale:4);

		var op2 = (SinOsc.ar(car_freq * 1.01) * 2.1) + (SinOsc.ar(car_freq * -24.midiratio * LFNoise2.kr(20).range(4,8)) * 0.6);
		//var op1 = (SinOsc.ar(car_freq * mod_ratio) * mod_index);
		var op1 = (SinOsc.ar( (car_freq * 12.midiratio) + op2) * mod_index);
		var sig = SinOsc.ar(car_freq + op1);
		sig * 0.5;
	};

	var env = Env.linen(attackTime:0.5, sustainTime:2, releaseTime:1).kr(gate:trig);

	var synths = [
		osc1.dup * env,
		osc2.dup()
	] * [1, 0.25].normalizeSum;

	var which = \which.kr(1);
	var focus = \focus.kr(0.3).clip(0.0, 1.0); // 0 = less focus -> 1 = more focus
	var sig = SelectXFocus.ar(
		which,
		synths,
		focus,
		wrap:true);

	//sig = JPverb.ar(sig, 5, 0, 5) * 0.3 + sig;
	sig = Splay.ar(sig, 0.5) * AmpCompA.kr(freq) * \amp.kr(-3.dbamp);
	sig;
};
)


/////////////////////////////////////////
// obj
q = q ? ();

/////////////////////////////////////////
// base pattern
(
q[\base2] = {arg node, params = [];

	Pdef(\base2, {
		if (node.isMonitoring.not) {node.play};
		Pbind(
			\type, \set,
			\id, Pfunc({node.nodeID}),
		)
	})
};
)

~s1.play;
~s1.isMonitoring

(
var node = ~s1;
Pdef(\s1, {

	q[\base2].(node)
	<> Pbind(
		\args, #[\trig, \freq, \amp],
		\amp, -6.dbamp,
		\scale, Scale.dorian,
		\octave, 4,
		\degree, Ppatlace([Pseq([0,7], inf), Pshuf([2,3,4,5], inf)], inf),
		\trig, 1,
		\dur, 4
	)
});
)
Pdef(\s1).play;
Pdef(\s1).stop;


(
var node = ~s1;
Pdef(\s2, {

	q[\base2].(node)
	<> Pbind(
		\args, #[\width, \trig],
		\width, Pseq([0.2, 0.7], inf),
		\trig, Prand([1,0], inf),
		\dur, 0.0625
	)
});
)
Pdef(\s2).play;
Pdef(\s2).stop;


(
var node = ~s1;
Pdef(\s3, {

	q[\base2].(node)
	<> Pbind(
		\args, #[\freq],
		\octave, Pseq([4,5], inf),
		\dur, Prand([1, 2, 0.5], inf)
	)
});
)
Pdef(\s3).play;
Pdef(\s3).stop;


(
var node = ~s1;
Pdef(\s4, {

	q[\base2].(node)
	<> Pbind(
		\args, #[\which],
		\which, Pwhite(0.0, 1.0, inf),
		\dur, 3
	)
});
)
Pdef(\s4).play;
Pdef(\s4).stop;

(
var node = ~s1;
Pdef(\s5, {

	q[\base2].(node)
	<> Pbind(
		\args, #[\focus],
		\focus, Pwhite(0.0, 1.0, inf),
		\dur, 0.5
	)
});
)
Pdef(\s5).play;
Pdef(\s5).stop;

~s1.play;
~s1.stop;

(
~s1_rev = {

	var in = \in.ar([0,0]);
	var fx = SoftClipAmp8.ar(in, 1.05) + ( ( (in ring1: SinOsc.ar(10)) * LFPulse.kr(1/4) + in ) * 0.3);
	fx = FbC({arg fb;
		PitchShift.ar(fb * 0.5 + fx, 0.5, 2, 0.01, 0.01)
	}, 3/4) * 0.7 + fx;
	fx = JPverb.ar(LPF.ar(fx, SinOsc.kr(1/8).range(880, 4400)), 20, 0, SinOsc.kr(1/64).range(0.1, 0.2)) * 0.8 + fx;
	//fx = RLPF.ar(fx, SinOsc.kr(1/16).range(110, 4400), LFTri.kr(1/8).range(0.2, 0.8));
	Splay.ar(fx, 0.5)
};
)

~s1_rev <<> ~s1
~s1_rev.play(vol:1);
Pdef(\s1_rev).play;

~s1_rev.stop;


Pdef(\s1_rev).stop;
Pdef(\s1_rev).clear;
(
var node = ~s1_rev;
Pdef(\s1_rev, Pbind(
	\type, \set,
	\id, Pfunc({node.nodeID}),
	\val, Pseq([5, 10], inf),
	\dur, 2
))
)

(~s1_rev[2] = nil\set -> Pbind(
	\val, Pseq([5, 10], inf),
	\dur, 2
))

~s1_rev.stop(fadeTime:8);


(
~s1_env = {
	var trig = \trig.tr;
	var in = \in.ar([0,0]);
	var fx = Env.perc.kr(gate:trig);
	in * fx;
}
)

~s1_env[2] = \set -> Pbind(\trig, 1, \dur, 2)
~s1_env <<> ~s1
~s1_env.play;
~s1_env.stop;
~s1.stop;

s.record;
s.stopRecording

