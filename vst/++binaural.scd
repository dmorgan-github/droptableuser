(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
            'azimuth', 'binaural_azimuth'.kr(0.5),
            'color', 'binaural_color'.kr(0.0),
            'filterset', 'binaural_filterset'.kr(0.0),
            'ingain', 'binaural_ingain'.kr(0.5),
            'lfodepth', 'binaural_lfodepth'.kr(0.0),
            'lfodivide', 'binaural_lfodivide'.kr(0.0),
            'lfolock', 'binaural_lfolock'.kr(0.0),
            'lfoshape', 'binaural_lfoshape'.kr(0.0),
            'lfospeed', 'binaural_lfospeed'.kr(0.5),
            'outgain', 'binaural_outgain'.kr(0.5),
        ],
        info:'++binaural'
    )
}
)