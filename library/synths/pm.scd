(
var func = {|freq, gate, aeg|

	var cutoff = \cutoff.kr(1000);
	var fvel = \fvel.kr(1);
	var res = \res.kr(0).linlin(0, 1, 0, 4);
	var op2 = SinOscFB.ar(freq * \op2ratio.kr(1), \fb.kr(0));
	var op1 = SinOsc.ar(freq, (op2 * \m1_2.kr(0)).mod(2pi));
	var sig = op1;
	//sig = MoogFF.ar(sig, aeg.linlin(0, 1, cutoff, cutoff * fvel), res) * 3;
	sig = [
		SinOsc.ar(freq/2) * \subamp.kr(0),
		sig
	].sum;
	sig = SinOsc.ar(0, (sig * \gain.kr(1).max(1)).mod(2pi));
	sig = LPF.ar(sig, \lpf.kr(20000));
	sig;
	//Limiter.ar(sig);
};

S.def(\pm2op, func);
S.def(\pm2op_mono, func, \mono);
S.def(\pm2op_perc, func, \perc);
)