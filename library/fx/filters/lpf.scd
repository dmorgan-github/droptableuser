(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var sig = BLowPass.ar(in,
		\freq.ar(1000).clip(20, 20000).lag(0.01),
		rq:\res.ar(0).linlin(0, 1, 1.4, 0.0001)
	);
	Splay.ar(sig,
		spread:\spread.ar(1),
		center:\pan.ar(0)
    ) * \output.ar(1);
},
specs: [
    \freq -> ControlSpec(20, 20000, \lin, 0, 1000, units:"fx"),
	\res -> ControlSpec(0, 1, \lin, 0, 0, units:"fx"),
	\spread -> ControlSpec(0,1,\lin,0, 1, units:"stereo"),
	\pan -> ControlSpec(-1,1,\lin,0,0, units:"stereo"),
    \input -> ControlSpec(0, 2, \lin, 0, 1, units:"vol"),
    \output -> ControlSpec(0, 1, \lin, 0, 1, units: "vol")
]
)