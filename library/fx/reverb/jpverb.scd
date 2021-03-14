(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var sig = JPverb.ar(in,
		t60:\t60.kr(1).lag(0.1),
		damp:\damp.kr(0),
		size:\size.kr(1).lag(0.1),
		earlyDiff:\earlyDiff.kr(0.707),
		modDepth:\modDepth.kr,
		modFreq:\modFreq.kr(2),
		low:\low.kr(1),
		mid:\mid.kr(1),
		high:\high.kr(1),
		lowcut:\lowcut.kr(500),
		highcut:\highcut.kr(2000)
	);

	Splay.ar(sig,
        spread:\spread.ar(1),
        center:\pan.ar(0)
    ) * \output.ar(1);
},
specs: [
    \t60 -> ControlSpec(0.1, 60, \lin, 0.0, 1, units:"fx"),
	\damp -> ControlSpec(0, 1, \lin, 0.0, 0, units:"fx"),
	\size -> ControlSpec(0.5, 5, \lin, 0, 1, units:"fx"),
	\earlyDiff -> ControlSpec(0, 1, \lin, 0, 0.707, units:"fx"),
	\modDepth -> ControlSpec(0, 1, \lin, 0, 0.1, units:"fx"),
	\modFreq -> ControlSpec(0, 10, \lin, 0, 2, units:"fx"),
	\low -> ControlSpec(0, 1, \lin, 0, 1, units:"fx"),
	\mid -> ControlSpec(0, 1, \lin, 0, 1, units:"fx"),
	\high -> ControlSpec(0, 1, \lin, 0, 1, units:"fx"),
	\lowcut -> ControlSpec(100, 6000, \exp, 1, 500, units:"fx"),
	\highcut -> ControlSpec(1000, 10000, \exp, 1, 2000, units:"fx"),
	\spread -> ControlSpec(0,1,\lin,0, 1, units:"stereo"),
	\pan -> ControlSpec(-1,1,\lin,0,0, units:"stereo"),
	\input -> ControlSpec(0, 2, \lin, 0, 1, units:"vol"),
    \output -> ControlSpec(0, 2, \lin, 0, 1, units: "vol")
]
)