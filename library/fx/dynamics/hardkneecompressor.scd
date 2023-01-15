// https://scsynth.org/t/multiband-compressor/3753/4

(
func: { |in|
    var sig;
    var attack = \comp_atk.kr(0.01, spec:ControlSpec(0.01, 1, \lin, 0, 0.01, "compress"));
    var release = \comp_rel.kr(0.1, spec:ControlSpec(0.01, 1, \lin, 0, 0.1, "compress"));
    var threshold = \comp_threshdb.kr(-20, spec:ControlSpec(-60, 0, \lin, 0, -20, "compress"));
    var ratio = \comp_ratio.kr(2, spec:ControlSpec(1, 16, \lin, 0, 2, "compress"));
	var amplitudeDb, gainDb, gain;
	amplitudeDb = Amplitude.ar(in, attack, release).ampdb;
	gainDb = ((amplitudeDb - threshold) * (1 / ratio - 1)).min(0);
	sig = in * gainDb.dbamp;
    sig = in.blend(sig, \comp_mix.kr(1, spec:ControlSpec(0, 1, \lin, 0, 1, "compress")));
    sig;
};
)



