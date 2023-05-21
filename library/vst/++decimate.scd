(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
            'color', 'decimate_color'.kr(0),
            'depth', 'decimate_depth'.kr(0.65512388944626),
            'folding', 'decimate_folding'.kr(0.26373896002769),
            'ingain', 'decimate_ingain'.kr(0.5),
            'outgain', 'decimate_outgain'.kr(0.5),
        ],
        info:'++decimate'
    )
}
)