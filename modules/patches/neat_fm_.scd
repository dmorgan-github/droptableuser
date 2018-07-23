
// from here
"https://scsynth.org/t/passif-1-2-3/26"

(
SynthDef (\stacked_fm) {
	arg freq = 440, amp = 1, pan = 0, len = 1, gate = 1, loopNode = 0,
	a1_tip = 0.5, a1_curve = 0, a1_amp = 1,
	a2_num = 1, a2_den = 1, a2_len = 1, a2_tip = 0.5, a2_curve = 0, a2_wid = 1,
	a3_num = 1, a3_den = 1, a3_len = 1, a3_tip = 0.5, a3_curve = 0, a3_wid = 1,
	b1_num = 1, b1_den = 1, b1_len = 1, b1_tip = 0.5, b1_curve = 0, b1_amp = 1,
	b2_num = 1, b2_den = 1, b2_len = 1, b2_tip = 0.5, b2_curve = 0, b2_wid = 1,
	b3_num = 1, b3_den = 1, b3_len = 1, b3_tip = 0.5, b3_curve = 0, b3_wid = 1;

	var sig,
	a_sig, a3_freq, a3_att, a3_dec, a3_env, a2_freq, a2_att, a2_dec, a2_env, a1_freq, a1_att, a1_dec, a1_env,
	b_sig, b3_freq, b3_att, b3_dec, b3_env, b2_freq, b2_att, b2_dec, b2_env, b1_freq, b1_att, b1_dec, b1_env;

	a1_freq = freq;
	a2_freq = a1_freq * a2_num / a2_den;
	a3_freq = a2_freq * a3_num / a3_den;

	b1_freq = a1_freq * b1_num / b1_den;
	b2_freq = b1_freq * b2_num / b2_den;
	b3_freq = b2_freq * b3_num / b3_den;

	a1_att = len * a1_tip;
	a1_dec = len * (1 - a1_tip);

	a2_len = a2_len * len;
	a2_att = a2_len * a2_tip;
	a2_dec = a2_len * (1 - a2_tip);

	a3_len = a3_len * a2_len;
	a3_att = a3_len * a2_tip;
	a3_dec = a3_len * (1 - a2_tip);

	b1_len = len * b1_len;
	b1_att = b1_len * b1_tip;
	b1_dec = b1_len * (1 - b1_tip);

	b2_len = b2_len * len;
	b2_att = b2_len * b2_tip;
	b2_dec = b2_len * (1 - b2_tip);

	b3_len = b3_len * b2_len;
	b3_att = b3_len * b2_tip;
	b3_dec = b3_len * (1 - b2_tip);

	a1_env = Env ([ 0, a1_amp, 0, 0], [ a1_att, a1_dec, 0 ], a1_curve, 2, loopNode);
	a1_env = EnvGen.kr (a1_env, gate, doneAction: 2);

	a2_env = Env ([ 0, a2_wid * a1_freq, 0, 0 ], [ a2_att, a2_dec, 0 ], a2_curve, 2, 0);
	a2_env = EnvGen.kr (a2_env, gate);

	a3_env = Env ([ 0, a3_wid * a2_freq, 0, 0 ], [ a3_att, a3_dec, 0 ], a3_curve, 2, 0);
	a3_env = EnvGen.kr (a3_env, gate);

	b1_env = Env ([ 0, b1_amp, 0 ], [ b1_att, b1_dec, 0 ], b1_curve, 2, 0);
	b1_env = EnvGen.kr (b1_env, gate) * a1_env; // keeps B under the A amp env

	b2_env = Env ([ 0, b2_wid * b1_freq, 0, 0 ], [ b2_att, b2_dec, 0 ], b2_curve, 2, 0);
	b2_env = EnvGen.kr (b2_env, gate);

	b3_env = Env ([ 0, b3_wid * b2_freq, 0, 0 ], [ b3_att, b3_dec, 0 ], b3_curve, 2, 0);
	b3_env = EnvGen.kr (b3_env, gate);

	a_sig = SinOsc.ar (a3_freq, 0, a3_env, a2_freq);
	a_sig = SinOsc.ar (a_sig, 0, a2_env, a1_freq);
	a_sig = SinOsc.ar (a_sig, 0, a1_env);

	b_sig = SinOsc.ar (b3_freq, 0, b3_env, b2_freq);
	b_sig = SinOsc.ar (b_sig, 0, b2_env, b1_freq);
	b_sig = SinOsc.ar (b_sig, 0, b1_env);

	sig = a_sig + b_sig;

	sig = Pan2.ar (sig, pan, amp);
	Out.ar (0, sig);
}.add;
)

(
~intArray = (1..12);
~curveArray = (-128..128);
~tip =  1;
~length = 0.42857142857143;
g = Group.new;
16.do {
	arg i;
	Routine {
		(~length * i * (2 ** -2)).wait;
		// rand (~length).wait;
		Synth (\stacked_fm, [
			\freq, (([0, 3, 7] + 64).choose + ([-24, -12, 0, 12, 24, 36].choose)).midicps,
			\amp, 0.1,
			// \pan, rrand (-1.0, 1.0),
			\pan, ((i % 2) * 2) - 1,

			\a2_num, ~intArray.choose,
			\a2_den, ~intArray.choose,
			\a3_num, ~intArray.choose,
			\a3_den, ~intArray.choose,
			\b1_num, ~intArray.choose,
			\b1_den, ~intArray.choose,
			\b2_num, ~intArray.choose,
			\b2_den, ~intArray.choose,
			\b3_num, ~intArray.choose,
			\b3_den, ~intArray.choose,

			\len, ~length * (2 ** (-1..3).choose) * (~intArray.choose / ~intArray.choose),
			\a2_len, 1 / ~intArray.choose,
			\a3_len, 1 / ~intArray.choose,
			\b1_len, 1 / ~intArray.choose,
			\b2_len, 1 / ~intArray.choose,
			\b3_len, 1 / ~intArray.choose,

			\a1_amp, 1.0,
			\a2_wid, rand (1.0),
			\a3_wid, rand (1.0),
			\b1_amp, rand (1.0),
			\b2_wid, rand (1.0),
			\b3_wid, rand (1.0),

			\a1_tip, rand (~tip),
			\a2_tip, rand (~tip),
			\a3_tip, rand (~tip),
			\b1_tip, rand (~tip),
			\b2_tip, rand (~tip),
			\b3_tip, rand (~tip),

			\a1_curve, ~curveArray.choose,
			\a2_curve, ~curveArray.choose,
			\a3_curve, ~curveArray.choose,
			\b1_curve, ~curveArray.choose,
			\b2_curve, ~curveArray.choose,
			\b3_curve, ~curveArray.choose,

		], g);
	}.play;
}
)