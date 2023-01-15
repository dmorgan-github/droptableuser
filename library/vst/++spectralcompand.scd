(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
            'attack', 'spectralcompand_attack'.kr(0.0),
            'averagelearn', 'spectralcompand_averagelearn'.kr(0.0),
            'bands', 'spectralcompand_bands'.kr(0.69999998807907),
            'color', 'spectralcompand_color'.kr(0.0),
            'ingain', 'spectralcompand_ingain'.kr(0.5),
            'invert', 'spectralcompand_invert'.kr(0.0),
            'outgain', 'spectralcompand_outgain'.kr(0.5),
            'peaklearn', 'spectralcompand_peaklearn'.kr(0.0),
            'ratio', 'spectralcompand_ratio'.kr(0.48835933208466),
            'release', 'spectralcompand_release'.kr(0.0),
            'stereolink', 'spectralcompand_stereolink'.kr(0.0),
            'threshold', 'spectralcompand_threshold'.kr(0.5),
            'threshreset', 'spectralcompand_threshreset'.kr(0.0),
            'tilt', 'spectralcompand_tilt'.kr(0.5)
        ],
        info:'++spectralcompand'
    )
}
)