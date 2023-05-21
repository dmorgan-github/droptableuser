(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
            'bands', 'morphfilter_bands'.kr(0.69999998807907),
            'color', 'morphfilter_color'.kr(0.0),
            'depth', 'morphfilter_depth'.kr(0.75),
            'envelopespeed', 'morphfilter_envelopespeed'.kr(0.0),
            'filternumber', 'morphfilter_filternumber'.kr(0.0),
            'ingain', 'morphfilter_ingain'.kr(0.5),
            'learn', 'morphfilter_learn'.kr(0.0),
            'lfodivide', 'morphfilter_lfodivide'.kr(0.0),
            'lfotempo', 'morphfilter_lfotempo'.kr(0.0),
            'makeupgain', 'morphfilter_makeupgain'.kr(0.5),
            'reset', 'morphfilter_reset'.kr(0.0),
            'stereolink', 'morphfilter_stereolink'.kr(0.0),
            'tilt', 'morphfilter_tilt'.kr(0.5)
        ],
        info:'++morphfilter'
    )
}
)