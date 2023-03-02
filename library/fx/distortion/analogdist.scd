(
synth: {|in|

    var compress;
    var drivegain = \anadist_drive.kr(0.5, spec:DMControlSpec(0, 1, \lin, 0, 0.5, "analogdist", sort:0));
    var dist_bias = \anadist_bias.kr(0, spec:DMControlSpec(0, 2.5, \lin, 0, 0, "analogdist", sort:1));
    var lowgain = \anadist_lowgain.kr(-20, spec:DMControlSpec(-60, -10, \lin, 0, -20, "analogdist", sort:2));
    var highgain = \anadist_higain.kr(-20, spec:DMControlSpec(-60, -10, \lin, 0, -20, "analogdist", sort:3));
    var shelvingfreq = \anadist_centerfreq.kr(600, spec:DMControlSpec(20, 20000, \exp, 0, 600, "analogdist", sort:4));
    var dist_oversample = \anadist_oversample.kr(1, spec:DMControlSpec(0, 4, \lin, 1, 1, "analogdist", sort:5));

    var sig = AnalogVintageDistortion.ar(in,
        drivegain,
        dist_bias,
        lowgain.dbamp,
        highgain.dbamp,
        shelvingfreq,
        dist_oversample
    );

    compress = {|in|
        var amplitudeDb, gainDb;
        var attack = \anadist_atk.kr(0.01, spec:DMControlSpec(0.01, 1, \lin, 0, 0.01, "analogdist", sort:6));
        var release = \anadist_rel.kr(0.1, spec:DMControlSpec(0.01, 1, \lin, 0, 0.1, "analogdist", sort:7));
        var threshold = \anadist_threshdb.kr(-20, spec:DMControlSpec(-60, 0, \lin, 0, -20, "analogdist", sort:8));
        var ratio = \anadist_ratio.kr(2, spec:DMControlSpec(1, 16, \lin, 0, 2, "analogdist", sort:9));
        amplitudeDb = Amplitude.ar(in, attack, release).ampdb;
        gainDb = ((amplitudeDb - threshold) * (1 / ratio - 1)).min(0);
        sig = in * gainDb.dbamp;
        sig;
    };

    sig = LeakDC.ar(sig);
    sig = compress.(sig);
    sig = in.blend(sig * 0.1, \anadist_mix.kr(0, spec:DMControlSpec(0, 1, \lin, 0, 0, "analogdist", sort:10)));
    sig;
},

doc: "
oversample: 0 = No oversampling, 1 = x2, 2 = x4, 3 = x8, 4 = x16
"
)

