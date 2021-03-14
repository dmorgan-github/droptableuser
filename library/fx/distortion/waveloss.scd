(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var sig = WaveLoss.ar(in,
		\drop.ar(20),
		\outof.ar(40),
		\mode.ar(1),
	);
	Splay.ar(LeakDC.ar(sig),
        spread:\spread.ar(1),
        center:\pan.ar(0)
    ) * \output.ar(1);
},
specs: [
    \drop -> ControlSpec(1,50,\lin,1,20, units:"fx"),
	\outof -> ControlSpec(1,100,\lin,1,40, units:"fx"),
	\mode -> ControlSpec(1,2,\lin,1,1, units:"fx"),
	\spread -> ControlSpec(0,1,\lin,0, 1, units:"stereo"),
	\pan -> ControlSpec(-1,1,\lin,0,0, units:"stereo"),
    \input -> ControlSpec(0, 10, \lin, 0, 1, units:"vol"),
    \output -> ControlSpec(0, 2, \lin, 0, 1, units: "vol")
]
)