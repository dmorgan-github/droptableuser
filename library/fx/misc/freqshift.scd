(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var freq = \freq.ar(3);
	var depth = \depth.ar(0);
	var fleft = freq - (freq * depth);
	var fright = freq + (freq * depth);
	var sig = FreqShift.ar(in, [fleft,fright]);
	Splay.ar(sig, spread:\spread.ar(1), center:\center.ar(0)) * \amp.ar(0.dbamp) * \vol.ar(0.dbamp);
},
specs: [
	\freq -> [0.0, 800, \lin, 0.0, 3],
	\depth -> [0, 1, \lin, 0, 0],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0],
	\amp -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1]
]
)