(
synth: {|in|

    var sig = VSTPlugin.ar(in, 2,
        params: [
            'color', 'flipper_color'.kr(0.0),
            'fliptime', 'flipper_fliptime'.kr(0.75),
            'ingain', 'flipper_ingain'.kr(0.5),
            'outgain', 'flipper_outgain'.kr(0.5),
            'overlap', 'flipper_overlap'.kr(0),
            'tempolock', 'flipper_tempolock'.kr(0.0)
        ],
        info:'++flipper'
    );

    //sig = in.blend(sig, \flipper_mix.kr(0.5, spec:ControlSpec(0, 1, \lin, 0, 0.5)));
    sig;
}
)