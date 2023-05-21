(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
            'bands', 'phasemash_bands'.kr(0.69999998807907),
            'bandscramble', 'phasemash_bandscramble'.kr(0.0),
            'bandshift', 'phasemash_bandshift'.kr(0.5),
            'color', 'phasemash_color'.kr(0.0),
            'ingain', 'phasemash_ingain'.kr(0.5),
            'outgain', 'phasemash_outgain'.kr(0.5),
            'phasenoise', 'phasemash_phasenoise'.kr(0.0),
            'phasenull', 'phasemash_phasenull'.kr(0.0),
            'phasereset', 'phasemash_phasereset'.kr(0.0),
            'phaseshift', 'phasemash_phaseshift'.kr(0.5)
        ],
        info:'++phasemash'
    )
}
)