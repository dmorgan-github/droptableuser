(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var sig = Disintegrator.ar(in,
		probability:\prob.ar(0.5),
		multiplier:\mult.ar(0)
	);
	Splay.ar(LeakDC.ar(sig),
        spread:\spread.ar(1),
        center:\pan.ar(0)
    ) * \output.ar(1);
},
specs: [
    \prob -> ControlSpec(0, 1, \lin, 0, 0.5, units:"fx"),
	\mult -> ControlSpec(-1, 1, \lin, 0, 0, units:"fx"),
	\spread -> ControlSpec(0,1,\lin,0, 1, units:"stereo"),
	\pan -> ControlSpec(-1,1,\lin,0,0, units:"stereo"),
    \input -> ControlSpec(0, 2, \lin, 0, 1, units:"vol"),
    \output -> ControlSpec(0, 2, \lin, 0, 1, units: "vol")
]
)