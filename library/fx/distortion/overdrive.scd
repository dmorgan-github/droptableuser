(
synth: {arg sig_in;

	var gain, sig, hi, lo;
	var in = sig_in * \input.ar(1);
	hi = HPF.ar(in, \hpf.kr(200));
	lo = hi - in;
	gain = [\gainL.ar(1).lag(0.01), \gainR.ar(1).lag(0.01)];
	sig = SoftClipAmp8.ar(hi, gain) * (gain.reciprocal.sqrt);
	sig = LeakDC.ar(sig) * 0.6;
	sig = sig + lo;
	Splay.ar(sig,
		spread:\spread.ar(1),
		center:\center.ar(0)
	) * [\ampL.ar(0.dbamp), \ampR.ar(0.dbamp)];

},
specs: [
	\gainL -> [1, 100, \lin, 0, 1],
	\gainR -> [1, 100, \lin, 0, 1],
	\hpf -> [20, 2000, \lin, 0, 80],
	\ampL -> [0,4,\lin,0,1],
	\ampR -> [0,4,\lin,0,1],
	\input -> [0, 10, \lin, 0, 1],
	\spread -> [0,1,\lin,0, 1],
	\center -> [-1,1,\lin,0,0]
]
)