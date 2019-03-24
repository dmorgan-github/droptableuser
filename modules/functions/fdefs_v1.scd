(
Fdef(\freq, {
	Vibrato.kr(\freq.kr(432).lag(\lag.kr(0.1)), \vrate.kr(6), \vdepth.kr(0));
});

Fdef(\mod, {arg freq, trig;

	var	modratio = \modratio.kr(2);
	var modenvhi = \modenvhi.kr(3);
	var modenvlo = \modenvlo.kr(0.01);
	var modenvdur = \modenvdur.kr(1);
	var modenvcurve = \modenvcurve.kr(4);

	var modindex = freq
	* modratio
	* Env([modenvhi, modenvhi, modenvlo], [0, modenvdur], modenvcurve).kr(gate:trig);

	var mod = SinOsc.ar(freq * modratio) * modindex;
	mod * \fm.kr(0);
});

Fdef(\adsr, {arg trig;
	Env([0,1,0.7,0.7,0],[\atk.kr(0.001), \dec.kr(0.01), \sus.kr(0), \rel.kr(1)], curve:\curve.kr(-4)).kr(gate:trig);
});

)