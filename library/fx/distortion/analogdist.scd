(
synth: {|in|

    var drivegain = \analogdist_drive.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5, "analogdist"));
    var dist_bias = \analogdist_bias.kr(0, spec:ControlSpec(0, 2.5, \lin, 0, 0, "analogdist"));
    var lowgain = \analogdist_lowgain.kr(0.1, spec:ControlSpec(0.0001, 0.3, \lin, 0, 0.1, "analogdist"));
    var highgain = \analogdist_higain.kr(0.1, spec:ControlSpec(0.0001, 0.3, \lin, 0, 0.1, "analogdist"));
    var shelvingfreq = \analogdist_shelvingfreq.kr(600, spec:ControlSpec(20, 20000, \exp, 0, 600, "analogdist"));
    var dist_oversample = \analogdist_oversample.kr(1, spec:ControlSpec(0, 4, \lin, 1, 1, "analogdist"));

    var sig = AnalogVintageDistortion.ar(in,
        drivegain,
        dist_bias,
        lowgain,
        highgain,
        shelvingfreq,
        dist_oversample
    );

    sig = LeakDC.ar(sig);
    sig = in.blend(sig * 0.1, \analogdist_mix.kr(0, spec:ControlSpec(0, 1, \lin, 0, 0, "analogdist")));
    sig;
},

notes: "
oversample: 0 = No oversampling, 1 = x2, 2 = x4, 3 = x8, 4 = x16
"
)