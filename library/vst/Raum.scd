(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
            'Damp', 'raum_damp'.kr(0.25),
            'Decay', 'raum_decay'.kr(0.63999998569489),
            'Density', 'raum_density'.kr(0.0),
            'Diffusion', 'raum_diffusion'.kr(0.25),
            'Feedback', 'raum_feedback'.kr(0.0),
            'Freeze', 'raum_freeze'.kr(0.0),
            'High Cut', 'raum_highcut'.kr(1.0),
            'Low Cut', 'raum_lowcut'.kr(0.0),
            'Mix', 'raum_mix'.kr(1.0),
            'MixLock', 'raum_mixlock'.kr(0.0),
            'Mode', 'raum_mode'.kr(0.5),
            'Modulation', 'raum_modulation'.kr(0.25),
            'Predelay', 'raum_predelay'.kr(0.0),
            'Reverb', 'raum_reverb'.kr(1.0),
            'Size', 'raum_size'.kr(0.5),
            'Sync', 'raum_sync'.kr(0.0),
        ],
        info:'Raum'
    )
}
)