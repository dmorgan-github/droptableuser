AdCVerb.maxTime = 10;
(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var sig = AdCVerb.ar(in,
		revTime:\revTime.ar(3),
		hfDamping:\hfDamping.ar(0.1),
		nOuts:2,
		predelay:\predelay.ar(0.02),
		numCombs:8,
		numAllpasses:4,
		inFilter:\inFilter.ar(0.6),
		combScale:\combScale.ar(3).lag(0.1),
		apScale:\apScale.ar(3).lag(0.1)
	);

	Splay.ar(sig, spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [
	\revTime -> [0.1, 60, \lin, 0.0, 3],
	\hfDamping -> [0, 1, \lin, 0.0, 0.1],
	\predelay -> [0, 30, \lin, 0, 0.02],
	\inFilter -> [0, 1, \lin, 0, 0.6],
	\combScale -> [0.1, 10, \lin, 0, 3],
	\apScale -> [0.1, 10, \lin, 0, 3],
	\spread -> [0, 1, \lin, 0, 1],
	\center -> [-1, 1, \lin, 0, 0],
	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1]
]
)
