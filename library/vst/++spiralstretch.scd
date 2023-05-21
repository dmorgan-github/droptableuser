(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
            'bands', 'spiralstretch_bands'.kr(0.69999998807907),
            'color', 'spiralstretch_color'.kr(0.0),
            'grainpvoc', 'spiralstretch_grainpvoc'.kr(0.0),
            'grainsize', 'spiralstretch_grainsize'.kr(0.48705968260765),
            'grainvariation', 'spiralstretch_grainvariation'.kr(0.0),
            'ingain', 'spiralstretch_ingain'.kr(0.5),
            'midilock', 'spiralstretch_midilock'.kr(0.0),
            'outgain', 'spiralstretch_outgain'.kr(0.5),
            'repeat', 'spiralstretch_repeat'.kr(0.66874033212662),
            'stretch', 'spiralstretch_stretch'.kr(0.44833865761757),
            'voices', 'spiralstretch_voices'.kr(0.0),
            'wetdry', 'spiralstretch_wetdry'.kr(0.5)
        ],
        info:'++spiralstretch'
    )
}
)