(
synth: {arg sig_in;

	var in = sig_in * \input.kr(1);

	var sig = NHHall.ar(in,
		\rt60.ar(1).lag(0.1),
		\stereo.ar(0.5),
		\lowFreq.ar(200),
		\lowRatio.ar(0.5),
		\hiFreq.ar(4000),
		\hiRatio.ar(0.5),
		\earlyDiffusion.ar(0.5),
		\lateDiffusion.ar(0.5),
		\modRate.ar(0.2),
		\modDepth.ar(0.3)
	);

	Splay.ar(sig, spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [
	\rt60 -> [0.1, 60, \lin, 0.0, 1],
	\stereo -> [0, 1, \lin, 0, 0.5],
	\lowFreq -> [20, 20000, \exp, 0, 200],
	\lowRatio -> [0, 1, \lin, 0, 0.5],
	\hiFreq -> [20, 20000, \exp, 0, 40000],
	\hiRatio -> [0, 1, \lin, 0, 0.5],
	\earlyDiffusion -> [0, 1, \lin, 0, 0.5],
	\lateDiffusion -> [0, 1, \lin, 0, 0.5],
	\modRate -> [0, 1, \lin, 0, 0.2],
	\modDepth -> [0,1,\lin, 0, 0.3],
	\spread -> [0, 1, \lin, 0, 1],
	\center -> [-1, 1, \lin, 0, 0],
	\amp -> [0,4,\lin, 0, 1],
	\input -> [0, 10, \lin, 0, 1]
]
)