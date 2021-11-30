(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
            'color', 'delay_color'.kr(0.0),
            'delaylock', 'delay_delaylock'.kr(0.0),
            'envmodulate', 'delay_envmodulate'.kr(0.0),
            'feedback', 'delay_feedback'.kr(0.0),
            'feedbackpositive', 'delay_feedbackpositive'.kr(0.0),
            'filterhipfreq', 'delay_filterhipfreq'.kr(0.0),
            'filterlopfreq', 'delay_filterlopfreq'.kr(1.0),
            'filterreson', 'delay_filterreson'.kr(0.10000000149012),
            'freeze', 'delay_freeze'.kr(0.0),
            'ingain', 'delay_ingain'.kr(0.5),
            'lfolock', 'delay_lfolock'.kr(0.0),
            'moddepth', 'delay_moddepth'.kr(0.0),
            'modphase', 'delay_modphase'.kr(0.5),
            'modshape', 'delay_modshape'.kr(0.0),
            'modspeed', 'delay_modspeed'.kr(0.49982836842537),
            'outgain', 'delay_outgain'.kr(0.5),
            'time', 'delay_time'.kr(0.23404595255852),
            'twohead', 'delay_twohead'.kr(0.0),
            'wetdry', 'delay_wetdry'.kr(0.5)
        ],
        info:'++delay'
    )
}
)