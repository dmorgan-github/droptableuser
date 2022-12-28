(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
            'color', 'bubbler_color'.kr(0.0),
            'density', 'bubbler_density'.kr(0.27114063501358),
            'feedback', 'bubbler_feedback'.kr(0.050984371453524),
            'filterfreq', 'bubbler_filterfreq'.kr(1.0),
            'filterreson', 'bubbler_filterreson'.kr(0.10000000149012),
            'grainsize', 'bubbler_grainsize'.kr(0.30464065074921),
            'grainstartvariation', 'bubbler_grainstartvariation'.kr(0.044124998152256),
            'ingain', 'bubbler_ingain'.kr(0.5),
            'just', 'bubbler_just'.kr(0.0),
            'octave', 'bubbler_octave'.kr(0.625),
            'octavevariation', 'bubbler_octavevariation'.kr(0.34234374761581),
            'outgain', 'bubbler_outgain'.kr(0.5),
            'panvariation', 'bubbler_panvariation'.kr(0.0),
            'pitcheight', 'bubbler_pitcheight'.kr(0.0),
            'pitcheleven', 'bubbler_pitcheleven'.kr(0.0),
            'pitchfive', 'bubbler_pitchfive'.kr(0.0),
            'pitchfour', 'bubbler_pitchfour'.kr(0.0),
            'pitchnine', 'bubbler_pitchnine'.kr(0.0),
            'pitchone', 'bubbler_pitchone'.kr(0.0),
            'pitchseven', 'bubbler_pitchseven'.kr(0.0),
            'pitchsix', 'bubbler_pitchsix'.kr(0.0),
            'pitchten', 'bubbler_pitchten'.kr(0.0),
            'pitchthree', 'bubbler_pitchthree'.kr(0.0),
            'pitchtwo', 'bubbler_pitchtwo'.kr(0.0),
            'pitchzero', 'bubbler_pitchzero'.kr(0.0),
            'reversegrain', 'bubbler_reversegrain'.kr(0.78679686784744),
            'time', 'bubbler_time'.kr(0.39915624260902),
            'timelock', 'bubbler_timelock'.kr(0.0),
            'timevariation', 'bubbler_timevariation'.kr(0.59892189502716),
            'wetdry', 'bubbler_wetdry'.kr(0.3)
        ],
        info:'++bubbler'
    )
}
)