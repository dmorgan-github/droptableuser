(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
            '1080out', 'phasor_1080out'.kr(0.0),
            '1440out', 'phasor_1440out'.kr(0.0),
            '360out', 'phasor_360out'.kr(1.0),
            '720out', 'phasor_720out'.kr(0.0),
            'bandwidth', 'phasor_bandwidth'.kr(0.48705968260765),
            'color', 'phasor_color'.kr(0.0),
            'feedback', 'phasor_feedback'.kr(0.5),
            'frequency', 'phasor_frequency'.kr(0.45803624391556),
            'ingain', 'phasor_ingain'.kr(0.5),
            'lfodepth', 'phasor_lfodepth'.kr(0.5),
            'lfoshape', 'phasor_lfoshape'.kr(0.0),
            'lfospeed', 'phasor_lfospeed'.kr(0.56107050180435),
            'outgain', 'phasor_outgain'.kr(0.5),
            'tempolock', 'phasor_tempolock'.kr(0.0)
        ],
        info:'++phasor'
    )
}
)