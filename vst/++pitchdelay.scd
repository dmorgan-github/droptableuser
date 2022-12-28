(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
            'cents', 'pitchdelay_cents'.kr(0.5),
            'color', 'pitchdelay_color'.kr(0.0),
            'delaylock', 'pitchdelay_delaylock'.kr(0.0),
            'feedback', 'pitchdelay_feedback'.kr(0.1631875038147),
            'ingain', 'pitchdelay_ingain'.kr(0.5),
            'just', 'pitchdelay_just'.kr(1.0),
            'loopdepth', 'pitchdelay_loopdepth'.kr(1.0),
            'octave', 'pitchdelay_octave'.kr(0.66666668653488),
            'outgain', 'pitchdelay_outgain'.kr(0.5),
            'pitchshift', 'pitchdelay_pitchshift'.kr(0.79166668653488),
            'time', 'pitchdelay_time'.kr(0.68981248140335),
            'wetdry', 'pitchdelay_wetdry'.kr(0.48650002479553)
        ],
        info:'++pitchdelay'
    )
}
)
