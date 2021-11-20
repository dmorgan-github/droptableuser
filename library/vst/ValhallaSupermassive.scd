(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
            'Feedback', 'valhallasupermassive_feedback'.kr(0.52600002288818),
            'DelayNote', 'valhallasupermassive_delaynote'.kr(0),
            'Delay_Ms', 'valhallasupermassive_delay_ms'.kr(0.23499999940395),
            'Density', 'valhallasupermassive_density'.kr(0),
            'LowCut', 'valhallasupermassive_lowcut'.kr(0),
            'ModRate', 'valhallasupermassive_modrate'.kr(0.46900001168251),
            'Mix', 'valhallasupermassive_mix'.kr(0.5),
            'Mode', 'valhallasupermassive_mode'.kr(0.16666667163372),
            'DelayWarp', 'valhallasupermassive_delaywarp'.kr(0.25299999117851),
            'DelaySync', 'valhallasupermassive_delaysync'.kr(0),
            'HighCut', 'valhallasupermassive_highcut'.kr(1.0),
            'ModDepth', 'valhallasupermassive_moddepth'.kr(0.072999998927116),
            'Width', 'valhallasupermassive_width'.kr(1.0),
        ],
        info:'ValhallaSupermassive'
    )
}
)