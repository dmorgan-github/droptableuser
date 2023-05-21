(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
            'bands', 'pitchsift_bands'.kr(0.69999998807907),
            'color', 'pitchsift_color'.kr(0.0),
            'harmonics', 'pitchsift_harmonics'.kr(1.0),
            'ingain', 'pitchsift_ingain'.kr(0.5),
            'just', 'pitchsift_just'.kr(1.0),
            'midivocoder', 'pitchsift_midivocoder'.kr(0.0),
            'octave', 'pitchsift_octave'.kr(0.5),
            'outgain', 'pitchsift_outgain'.kr(0.5),
            'pitch', 'pitchsift_pitch'.kr(0.5),
            'pitchfine', 'pitchsift_pitchfine'.kr(0.5),
            'sinebank', 'pitchsift_sinebank'.kr(1.0),
            'threshold', 'pitchsift_threshold'.kr(0.5)
        ],
        info:'++pitchshift'
    )
}
)