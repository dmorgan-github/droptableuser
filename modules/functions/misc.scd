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

Fdef(\dfm1_env, {arg sig, env, freq, num = 1;

	var depth = \filtdepth.kr(1);
	var ffreqmult = \filtmult.kr(2);
	var ffreqmax = (freq * ffreqmult * depth);
	var ffreqmin = (freq * ffreqmult * depth.reciprocal);
	var res = \res.kr(0.1);
	{ sig = DFM1.ar(sig, env.exprange(ffreqmin, ffreqmax).clip(20, 20000), res) }.dup(num);
	sig;
});

Fdef(\dfm1_line, {arg sig, trig, num = 1;

	var res = \res.kr(0.1);
	var filthi = \filthi.kr(2200);
	var filtlo = \filtlo.kr(440);
	var filtdur = \filtdur.kr(1);
	var filtcurve = \filtcurve.kr(0);

	{ sig = DFM1.ar(sig, Env(
		[filthi,filthi,filtlo],
		[0,filtdur], filtcurve).kr(gate:trig).clip(20, 20000), res) }.dup(num);
	sig;
});

Fdef(\filt_env, {arg filt=\rlpf, sig, env, freq, num=1;

	var depth = \filtdepth.kr(1);
	var ffreqmult = \filtmult.kr(2);
	var ffreqmax = (freq * ffreqmult * depth);
	var ffreqmin = (freq * ffreqmult * depth.reciprocal);
	var res = \res.kr(0.5);

	case
	{filt == \dfm1} {
		{ sig = DFM1.ar(sig, env.exprange(ffreqmin, ffreqmax).clip(20, 20000), res) }.dup(num);
	}
	{filt == \moog} {
		{ sig = MoogFF.ar(sig, env.exprange(ffreqmin, ffreqmax).clip(20, 20000), res.linlin(0,1,0,4)) }.dup(num);
	}
	{filt == \rlpf} {
		{ sig = RLPF.ar(sig, env.exprange(ffreqmin, ffreqmax).clip(20, 20000), res.linlin(0,1,1,0)) }.dup(num);
	};

	sig;
});

Fdef(\filt_line, {arg filt=\rlpf, sig, trig, num = 1;

	var res = \res.kr(0.5);
	var filthi = \filthi.kr(2200);
	var filtlo = \filtlo.kr(440);
	var filtdur = \filtdur.kr(1);
	var filtcurve = \filtcurve.kr(0);
	var env = Env([filthi,filthi,filtlo],[0,filtdur], filtcurve).kr(gate:trig).clip(20, 20000);

	case
	{filt == \dfm1} {
		{ sig = DFM1.ar(sig, env, res) }.dup(num);
	}
	{filt == \moog} {
		{ sig = MoogFF.ar(sig, env, res.linlin(0,1,0,4)) }.dup(num);
	}
	{filt == \rlpf} {
		{ sig = RLPF.ar(sig, env, res.linlin(0,1,1,0)) }.dup(num);
	};

	sig;
})

)

/*
~buf = Buffer.alloc(s, 44100 * 16, 2);
	{
		RecordBuf.ar(sig, ~buf, recLevel:1.0);
	}.();

	sig = sig.blend(
		PlayBufCF.ar(2, bufnum:~buf, rate:-1.5, trigger:Dust.kr(1/8), startPos:0, loop:1, lag:0.1, n:4),
		0.3
	);
	*/

~bufplay = {
	var trig = \trig.tr;
	var buf = \buf.kr(0);
	var rate = \rate.kr(1);
	var sig = PlayBuf.ar(1, buf, rate, trigger:trig, startPos:0, loop:0);
	sig;
};

~sinosc = {
	var trig = \trig.tr;
	var freq = ~freq.();
	var sig = SinOsc.ar(freq);
	var env = Env.perc(\atk.kr(0.01), \rel.kr(1), curve:\curve.kr(-4)).kr(gate:trig);
	sig * env * AmpCompA.kr(freq) * \amp.kr(-6.dbamp);
};

)