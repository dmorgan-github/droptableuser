(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
            'color', 'matrix_color'.kr(0.0),
            'direction', 'matrix_direction'.kr(0.0),
            'ingain', 'matrix_ingain'.kr(0.5),
            'midgain', 'matrix_midgain'.kr(0.5),
            'outgain', 'matrix_outgain'.kr(0.5),
            'sidegain', 'matrix_sidegain'.kr(0.5)
        ],
        info:'++matrix'
    )
}
)