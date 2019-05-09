Ndef(\fm7) = Fdef(\fm7);

(
Ndef(\env1, {
	Env.perc(releaseTime:0.1, curve:-24).kr(gate:\trig.tr).range(0, 1)
})
)

Ndef(\synth_v2)[0] = Fdef(\varsaw);

(
Ndef(\synth_v2).filter(20, {arg in;
	FbC({arg fb; PitchShift.ar(fb.reverse, 0.1, 2, 0.01, 0.01).tanh * 0.7 + in}, 0.3);
}).set(\wet20, 0.4)
)


Ndef(\synth_arc)[0] = \mix -> {Ndef(\fm7).ar};
Ndef(\synth_arc)[1] = \mix -> {Ndef(\synth_v2).ar};
Ndef(\synth_arc).set(\mix0, 0.4)

(
Ndef(\synth_arc).filter(20, {arg in;
	var sig = JPverb.ar(in, 2, 0, SinOsc.kr(1/64).range(3,4));
	sig;
}).set(\wet20, 0.3)
)

(
Ndef(\synth_arc).filter(30, {arg in;
	var sig = Fold.ar(in * 2, SinOsc.kr(1/32).range(-1.0, -0.1), SinOsc.kr(1/64).range(0.1, 1.0));
	LeakDC.ar(sig);
}).set(\wet30, 0.4)
)

(
Ndef(\synth_arc).filter(40, {arg in;
	var sig = RLPF.ar(in, SinOsc.kr(1/24).range(880, 4200), SinOsc.kr(1/19).range(0.5, 0.9));
	sig;
}).set(\wet40, 0)
)



(
Pdef(\fm7, {

	var node = Ndef(\synth_arc);
	node.play;

	Pbind(

		\type, \set,
		\id, Pfunc({
			[
				Ndef(\fm7).nodeID,
				Ndef(\synth_v2).nodeID,
				Ndef(\env1).nodeID,
			]
		}),
		\args, #[\trig, \freq,

			\sus, \rel, \dec,

			\r0, \r1, \r2, \r3, \r4, \r5,
			\c0, \c1, \c2, \c3, \c4, \c5,
			\m_0_0, \m_0_1, \m_0_2, \m_0_3, \m_0_4, \m_0_5,
			\m_1_0, \m_1_1, \m_1_2, \m_1_3, \m_1_4, \m_1_5,
			\m_2_0, \m_2_1, \m_2_2, \m_2_3, \m_2_4, \m_2_5,
			\m_3_0, \m_3_1, \m_3_2, \m_3_3, \m_3_4, \m_3_5,
			\m_4_0, \m_4_1, \m_4_2, \m_4_3, \m_4_4, \m_4_5,
			\m_5_0, \m_5_1, \m_5_2, \m_5_3, \m_5_4, \m_5_5,

			\chan0, \chan2,
			\spread,
			\vdepth,
			\vrate
		],

		\scale, Scale.aeolian.tuning_(\just),
		\d1, Ppatlace([Pshuf([0, 1, 2, 3, 4], inf), Pwhite(4, 7)], inf),
		\d2, Pkey(\d1),// + Pseq([2, 4, 9], inf),
		\count, Pseries(0, 1, inf),
		\degree, Ptuple([
			Pkey(\d1),
			Pif( Pfunc({arg evt; evt[\count].mod(2) == 0}), Pkey(\d2), Rest()).stutter(2),
			0
		], inf),

		\octave, Pbjorklund(3, 8).collect({arg val; if (val == 1) {6}{5}}) - 1,

		\r0, 1,
		\r1, 2.01,
		\r2, 1,
		\r3, Pbjorklund(5, 11).collect({arg val; if (val == 1) {12.5}{5.5}}),
		\r4, 4,
		\r5, 6.01,

		\c0, 1,
		\c1, 1,
		\c2, Ndef(\env1),
		\c3, Ndef(\env1),
		\c4, Ndef(\env1),
		\c5, Ndef(\env1),

		\m_0_1, 0.15pi,

		\m_2_3, 1pi,
		\m_3_4, 1pi,
		\m_4_5, 1pi,
		\m_5_5, 2pi, // feedback

		\chan0, 1,
		\chan2, 1,

		\dec, 0.1,
		\sus, 1,
		\rel, 1,

		\trig, 1,
		\spread, [0, 1, 0],
		\vdepth, 0.1,
		\vrate, 50,

		\dur, 1
	)
})
)

Pdef(\fm7).play;
Pdef(\fm7).stop;


App.saveWorkspace("beat", rec:true);
s.stopRecording