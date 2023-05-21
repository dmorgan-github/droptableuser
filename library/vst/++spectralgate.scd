(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
            'attack', 'spectralgate_attack'.kr(0.0),
            'bands', 'spectralgate_bands'.kr(0.69999998807907),
            'color', 'spectralgate_color'.kr(0.0),
            'gain', 'spectralgate_gain'.kr(0.5),
            'ingain', 'spectralgate_ingain'.kr(0.5),
            'invert', 'spectralgate_invert'.kr(0.0),
            'learn', 'spectralgate_learn'.kr(0.0),
            'makeupgain', 'spectralgate_makeupgain'.kr(0.5),
            'peaktrack', 'spectralgate_peaktrack'.kr(0.0),
            'release', 'spectralgate_release'.kr(0.0),
            'reset', 'spectralgate_reset'.kr(0.0),
            'stereolink', 'spectralgate_stereolink'.kr(0.0),
            'threshold', 'spectralgate_threshold'.kr(0.5),
            'tilt', 'spectralgate_tilt'.kr(0.5),
            'type', 'spectralgate_type'.kr(0.0)
        ],
        info:'++spectralgate'
    )
}
)