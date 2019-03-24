(
SynthDef(\industrial, {

	var freqshift = \freqshift.kr(3);

	var env = Env(
		[0,1,0.5,0.5,0],
		[\atk.kr(0.001), \decay.kr(0.3), \sus.kr(1), \rel.kr(1)],
		curve:\curve.kr(-4)
	).kr(gate:\trig.tr);

	var sig = WhiteNoise.ar;
	sig = Ringz.ar(HPF.ar(sig, \hpf.kr(1200)), 48 * [1, 2, 4, 8], 4);
	sig = FbC({arg fb; fb * \fb.kr(1) + sig}, 0.1).tanh * \fbmix.kr(0.7) + sig;
	sig = sig * LFPulse.kr(\rate.kr(3));
	sig = [sig, (FreqShift.ar(sig, [freqshift.neg, freqshift]) * \drive.kr(2)).tanh].sum;

	sig = sig * env * \amp.kr(-6.dbamp);

	sig = Splay.ar(sig.flatten);

	sig = JPverb.ar(sig, 5, 0, 3) * 0.5 + sig;

	Out.ar(\out.kr(0), sig);

}).add;
)

(
Pdef(\industrial_beat, Ppar([

	Pmono(\industrial,
		\trig, 1,
		\delta, 4,
		\foo, Pseq([
			Pseq([1], 2),
			//Pseq([\], 2)
		], inf),

		\hpf, 8000,
		\rate, 4,

		\sus, 3,
		\rel, 1,
		\amp, -15.dbamp * 1
	),

	Pmono(\industrial,

		\trig, 1,
		\delta, 1,
		\foo, Pseq([
			Pseq([1], 8),
			//Pseq([\], 8)
		], inf),

		\hpf, 800,
		\rate, 2,

		\sus, 0.1,
		\rel, 1,
		\amp, -25.dbamp * 1;
	)
]))
)


Pdef(\industrial_beat).play;
Pdef(\industrial_beat).stop;

