(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var sig = LADSPA.ar(1, 1605,
		in,
		\delay.ar(1).lag(0.1),
		-70, // dry
		0, // wet
		\feedback.ar(0.5).lag(0.1),
		\crossfade.ar(20)
	);

	Splay.ar(sig, spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [
	\delay -> [0, 5, \lin, 0, 1],
	\feedback -> [0, 1, \lin, 0, 0.5],
	\crossfade -> [0, 100, \lin, 0, 20],
	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0],
]
)