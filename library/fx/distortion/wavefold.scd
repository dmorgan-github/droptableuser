(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var gain = \gain.ar(1);
	var sig = (in * gain).fold(-1, 1) * (gain.reciprocal.sqrt);
	Splay.ar(LeakDC.ar(sig),
        spread:\spread.ar(1),
        center:\pan.ar(0)
    ) * \output.ar(1);
},
specs: [
	\gain -> ControlSpec(1, 20, \lin, 0, 1, units:"fx"),
	\spread -> ControlSpec(0,1,\lin,0, 1, units:"stereo"),
	\pan -> ControlSpec(-1,1,\lin,0,0, units:"stereo"),
    \input -> ControlSpec(0, 2, \lin, 0, 1, units:"vol"),
    \output -> ControlSpec(0, 2, \lin, 0, 1, units: "vol")
]
)