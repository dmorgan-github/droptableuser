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

	Splay.ar(sig, spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [
	\t60 -> [0.1, 60, \lin, 0.0, 1],
	\damp -> [0, 1, \lin, 0.0, 0],
	\size -> [0.5, 5, \lin, 0, 1],
	\earlyDiff -> [0, 1, \lin, 0, 0.707],
	\modDepth -> [0, 1, \lin, 0, 0.1],
	\modFreq -> [0, 10, \lin, 0, 2],
	\low -> [0, 1, \lin, 0, 1],
	\mid -> [0, 1, \lin, 0, 1],
	\high -> [0, 1, \lin, 0, 1],
	\lowcut -> [100, 6000, \exp, 1, 500],
	\highcut -> [1000, 10000, \exp, 1, 2000],
	\spread -> [0, 1, \lin, 0, 1],
	\center -> [-1, 1, \lin, 0, 0],
	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1]
]
)