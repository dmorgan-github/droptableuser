(
var sine = {|freq, gate, aeg|
	var gain = \gain.kr(1).max(1);
	var sig = SinOsc.ar(freq);
	sig = SinOsc.ar(freq: 0, phase: (sig * gain).mod(2pi));
	sig = LPF.ar(sig, 1000);
	sig;
};
S.def(\sine_perc, sine);
S.def(\sine_perc, sine, \perc);
S.def(\sine_mono, sine, \mono);
)