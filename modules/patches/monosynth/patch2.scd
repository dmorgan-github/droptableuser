Fdef(\filtpulse1).(\filtpulse1_s1);

(
Pdef(\filtpulse1_s1_v1,
	Pchain(
		Pbind(

			\octave, 6,
			\scale, Scale.aeolian,
			\degree, Pseq([0, 3, -2, 7], inf),

			\amp, -12.dbamp,
			\dur, 0.25,
			\rel, 0.3,

			// lpf
			\lpf, Pfunc({arg evt; evt[\freq]}) * 1.5,
			\lpf_res, 0.5,
			\lpf_rate, 1/4 * Pkey(\beat_dur),
			\lpf_range, 2,

			// bpf
			\bpf, Pfunc({arg evt; evt[\freq]}),
			\bpf_bw, 0.2,
			\bpf_rate, 13,
			\bpf_range, 3,

			// hpf
			\hpf, Pfunc({arg evt; evt[\freq]}) * 0.5,
			\hpf_res, 0.2,

			// mix filters
			\filt_which, 0,
			\filt_focus, 0.7,
			\filt_wet, 1,

			// fm
			\fm, 0.0,
			\modenvdur, 1,
			\modratio, 2.01,
			\modenvhi, 3,
			\modenvlo, 0.01,
			\modenvcurve, -4,

			// delay
			\del_l, 3/8,
			\del_r, 3/16,
			\del_fb, 0.5,
			\del_wet, 0.4,

			// reverb
			\rev_wet, 0.3,
			\rev_t60, 5,

			// distortion
			\dist_wet, 0.5,
			\pregain, 1.1
		),

		Pdef(\filtpulse1_s1),
	)
)
)

Pdef(\filtpulse1_s1_v1).play;
Pdef(\filtpulse1_s1_v1).stop;

