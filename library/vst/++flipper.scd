(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
            'color', 'flipper_color'.kr(0.0),
            'fliptime', 'flipper_fliptime'.kr(0.48705968260765),
            'ingain', 'flipper_ingain'.kr(0.5),
            'outgain', 'flipper_outgain'.kr(0.5),
            'overlap', 'flipper_overlap'.kr(0.15000000596046),
            'tempolock', 'flipper_tempolock'.kr(0.0)
        ],
        info:'++flipper'
    )
}
)