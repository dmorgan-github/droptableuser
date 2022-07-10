// https://scsynth.org/t/multiband-compressor/3753/4

(
func: { |in|
    var attack = \compatk.kr(0.01, spec:ControlSpec(0.01, 1, \lin, 0, 0.01, "compress"));
    var release = \comprel.kr(0.1, spec:ControlSpec(0.01, 1, \lin, 0, 0.1, "compress"));
    var threshold = \compthreshdb.kr(-20, spec:ControlSpec(-60, 0, \lin, 0, -20, "compress"));
    var ratio = \compratio.kr(2, spec:ControlSpec(1, 16, \lin, 0, 2, "compress"));
	var amplitudeDb, gainDb;
	amplitudeDb = Amplitude.ar(in, attack, release).ampdb;
	gainDb = ((amplitudeDb - threshold) * (1 / ratio - 1)).min(0);
	in * gainDb.dbamp;
};
)
