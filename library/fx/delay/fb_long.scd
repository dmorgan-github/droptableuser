(
synth: {arg sig_in;
	var in = sig_in * \input.ar(1);
	var fblevel = \fb.ar(0.7);
	var del = \del.ar(6).lag(0.1);
	var sig = FbC({arg fb;
		fb.reverse * fblevel + Select.ar(fblevel > 0.99, [in, Silent.ar(2)])
	}, 16, del);
	Splay.ar(sig,
		spread:\spread.ar(1),
		center:\center.ar(0)
	)
},
specs: [
	\fb -> [0.0, 1, \lin, 0.0, 0.7],
	\del -> [1, 16, \lin, 1, 6],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0],
	\input -> [0, 10, \lin, 0, 1]
]
)