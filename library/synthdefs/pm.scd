(
var func = {|freq, gate, aeg|

	var menv = Select.ar(\menv.ar(0), [
		aeg,
		Env.perc(\matk.kr(0.01), \mrel.kr(0.1), curve:\mcurve.kr(-4)).ar(gate:gate)
	]);
	var op2 = SinOscFB.ar(freq * \op2ratio.kr(1), \fb.kr(0));
	var op1 = SinOsc.ar(freq, (op2 * \op1_m2.kr(0) * menv).mod(2pi));
	var sig = [op1 * \op1.kr(1), op2 * \op2.kr(0)].sum;
	var gain = \gain.kr(1).max(1);

	sig = SinOsc.ar(0, (sig * gain).mod(2pi)) * gain.reciprocal.sqrt;
	sig = [
		SinOsc.ar(freq/2) * \sub.kr(0),
		sig
	].sum;
	sig = LPF.ar(sig, \lpf.kr(20000));
	sig = HPF.ar(sig, \hpf.kr(20));
	sig
};

S.def(\pm2op, func);
S.def(\pm2op_mono, func, \mono);
S.def(\pm2op_perc, func, \perc);
)
