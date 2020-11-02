(
synth: {arg sig_in;

	var in = sig_in * \input.ar(1);
	var fblevel = [\fbL.ar(0.3), \fbR.kr(0.5)];
	var delL = \delL.ar(6).lag(0.1) * 16.reciprocal;
	var delR = \delR.ar(10).lag(0.1) * 16.reciprocal;
	var tempo = \tempo.ar(1).lag(0.1);
	var time = \offset.ar(0).lag(0.1);

	var sig = HPF.ar(in, \inhpf.kr(20));
	sig = FbC({arg fb; fb.reverse * fblevel + sig}, 5, [delL, delR] * tempo + time);

	sig = Splay.ar(sig, \spread.kr(0.5), 1, center:\center.kr(0));
	sig * [\ampL.ar(0.dbamp), \ampR.ar(0.dbamp)];
},
specs: [
	\fbL -> ControlSpec(0.0, 1, \lin, 0.0, 0.3, "fb"),
	\fbR -> ControlSpec(0.0, 1, \lin, 0.0, 0.5, "fb"),
	\delL -> ControlSpec(1, 16, \lin, 1, 6, "delay"),
	\delR -> ControlSpec(1, 16, \lin, 1, 10, "delay"),
	\inhpf -> ControlSpec(20, 10000, \lin, 0, 20, "filter"),
	\tempo -> ControlSpec(0.001, 4, \lin, 0.0, 1, "delay"),
	\offset -> ControlSpec(0.0, 4, \lin, 0.0, 0, "delay"),
	\center -> ControlSpec(-1, 1, \lin, 0, 0, "stereo"),
	\spread -> ControlSpec(0, 1, \lin, 0, 0.5, "stereo"),
	\ampL -> ControlSpec(0,4,\lin,0, 1, "vol"),
	\ampR -> ControlSpec(0,4,\lin,0, 1, "vol"),
	\input -> ControlSpec(0, 10, \lin, 0, 1, "vol")
]
)