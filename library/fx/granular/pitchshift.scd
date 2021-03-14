(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var sig = PitchShift.ar(in,
		0.5,
		\pitchRatio.ar(12).midiratio,
		\pitchDispersion.ar(0.01),
		\timeDispersion.ar(0.01)
	);

	Splay.ar(sig,
        spread:\spread.ar(1),
        center:\pan.ar(0)
    ) * \output.ar(1);
},
specs: [
	\pitchRatio -> ControlSpec(-24, 24, \lin, 1, 12, units:"fx"),
	\pitchDispersion -> ControlSpec(0, 1, \lin, 0.0, 0.01, units:"fx"),
	\timeDispersion -> ControlSpec(0.0, 0.5, \lin, 0, 0.01, units:"fx"),
	\spread -> ControlSpec(0,1,\lin,0, 1, units:"stereo"),
	\pan -> ControlSpec(-1,1,\lin,0,0, units:"stereo"),
    \input -> ControlSpec(0, 2, \lin, 0, 1, units:"vol"),
    \output -> ControlSpec(0, 2, \lin, 0, 1, units: "vol")
]
)