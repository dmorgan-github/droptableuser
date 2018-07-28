~p = ~p ? ProxySpace.new(s, \p);
~p.quant = 1.0;

(
SynthDef(\polysynth1, {

	var freq_in = \freq.kr(432);

	var freq = Vibrato.ar(K2A.ar(freq_in.lag(\lag.kr(0.0))),
		\vrate.kr(6),
		\vdepth.kr(0.0),
		\vdelay.kr(0),
		\vonset.kr(0),
		\vrateVar.kr(0.04),
		\vdepthVar.kr(0.1)
	);

	var osc1 = {

		var freqmul = \osc1_freqmul.kr(1);
		var sig = SinOsc.ar(freq * freqmul);
		var env = Env.adsr(
			\osc1_atk.kr(0.01),
			\osc1_decay.kr(0.3),
			\osc1_susLevel.kr(0.5),
			\osc1_rel.kr(1),
			curve:\osc1_curve.kr(-4)
		).kr(gate:\gate.kr(1));

		//(sig * 2).tanh * env * \osc1.kr(0.5);
		sig * env * \osc1.kr(0.5);
	};

	var osc2 = {

		var freqmul = \osc2_freqmul.kr(1);
		var sig = VarSaw.ar(freq * freqmul, width:\width.kr(0.5));
		var env = Env.adsr(
			\osc2_atk.kr(0.01),
			\osc2_decay.kr(0.3),
			\osc2_susLevel.kr(0.5),
			\osc2_rel.kr(1),
			curve:\osc2_curve.kr(-4)
		).kr(gate:\gate.kr(1));

		var num = 1;
		{ sig = LPF.ar(sig, 5300 ) }.dup(num);

		sig * env * \osc2.kr(0.5);// * res.reciprocal.sqrt * num;
	};

	var osc3 = {

		var freqmul = \osc3_freqmul.kr(1);
		var sig = Saw.ar(freq * freqmul);
		var env = Env.adsr(
			\osc3_atk.kr(0.01),
			\osc3_decay.kr(0.3),
			\osc3_susLevel.kr(0.5),
			\osc3_rel.kr(1),
			curve:\osc3_curve.kr(-4)
		).kr(gate: \gate.kr(1) );

		var res = 0.5;
		var num = 2;

		{ sig = MoogLadder.ar(sig, Line.kr(6000, 220, \osc3_rel.kr), res ) }.dup(num);

		sig * env * \osc3.kr(0) * (res.reciprocal.sqrt * num);
	};

	var sig = [osc1.(), osc2.(), osc3.()];

	sig = Pan2.ar(sig.sum) * AmpCompA.kr(freq) * \amp.kr(0.3);

	DetectSilence.ar(sig, doneAction:Done.freeSelf);

	Out.ar(\out.kr(0), sig);

}).add
)

(
var circle = Library.at(\circle);
~p[\chords][0] = Pbind(

	\instrument, \polysynth1,
	[\osc1, \osc2, \osc3], #[0.3, 0.7, 0.5].normalizeSum,
	\lag, 0.01,
	\vdepth, 0.005,

	\osc1_freqmul, [0.5, 2],
	\osc1_rel, 1,
	\osc1_decay, 0.3,
	\osc1_curve, -4,

	\osc2_atk, 0.07,
	\osc2_susLevel, 0.1,
	\osc2_rel, 0.5,

	\osc3_freqmul, 2.01,
	\osc3_curve, -4,
	\osc3_atk, 0.01,
	\osc3_rel, 1,

	\width, 0.5,
	\scale, Scale.major,
	\dur, 2, //Prand([0.5, 0.25, 0.33, 1], inf),
	\sustain, Pkey(\dur) * 1.1,
	\legato, 1.5,
	\octave, Prand([4,5], inf),
	\degree, Pshuf(circle.values, inf).collect({arg val;
		var max = val.maxItem;
		var returnVal = val;
		if (0.1.coin) {
			returnVal = returnVal ++ [max + 2];
		};
		returnVal;
	}),
	\amp, 0.8
))
)
~p[\chords].play;
~p[\chords].stop;


App.recordWorkspace("ws13");
s.stopRecording;
