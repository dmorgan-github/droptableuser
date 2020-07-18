(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var sig = PitchShift.ar(in,
		0.5,
		\pitchRatio.ar(12).midiratio,
		\pitchDispersion.ar(0.01),
		\timeDispersion.ar(0.01)
	);

	Splay.ar(sig, spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [
	\pitchRatio -> [-24, 24, \lin, 1, 12],
	\pitchDispersion -> [0, 1, \lin, 0.0, 0.01],
	\timeDispersion -> [0.0, 0.5, \lin, 0, 0.01],
	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)