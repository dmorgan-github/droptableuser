(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
            'Attack', 'mcompressor_attack'.kr(0.1),
            'Custom shape', 'mcompressor_customshape'.kr(0.0),
            'Gain', 'mcompressor_gain'.kr(0.5),
            'Knee mode', 'mcompressor_kneemode'.kr(1.0),
            'Knee size', 'mcompressor_kneesize'.kr(0.25),
            'Link channels', 'mcompressor_linkchannels'.kr(1.0),
            'Maximize to 0dB', 'mcompressor_maximizeto0db'.kr(0.0),
            'Output gain', 'mcompressor_outputgain'.kr(0.5),
            'Param 1', 'mcompressor_param1'.kr(0.49990636110306),
            'Param 2', 'mcompressor_param2'.kr(0.5),
            'Param 3', 'mcompressor_param3'.kr(0.5),
            'Param 4', 'mcompressor_param4'.kr(0.5),
            //'Preset trigger - next', 'mcompressor_presettriggernext'.kr(0.0),
            //'PresetTrigger-Previous', 'mcompressor_presettriggerprevio'.kr(0.0),
            'RMS length', 'mcompressor_rmslength'.kr(0.10000000149012),
            'Ratio', 'mcompressor_ratio'.kr(0.2051956653595),
            'Release', 'mcompressor_release'.kr(0.1),
            'Threshold', 'mcompressor_threshold'.kr(0.5)
        ],
        info:'MCompressor'
    )
}
)

