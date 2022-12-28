(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
            'color', 'chebyshev_color'.kr(0.0),
            'gainfive', 'chebyshev_gainfive'.kr(0.0),
            'gainfour', 'chebyshev_gainfour'.kr(0.0),
            'gainone', 'chebyshev_gainone'.kr(1.0),
            'gainseven', 'chebyshev_gainseven'.kr(0.0),
            'gainthree', 'chebyshev_gainthree'.kr(0.0),
            'gaintwo', 'chebyshev_gaintwo'.kr(0.0),
            'ingain', 'chebyshev_ingain'.kr(0.5),
            'outgain', 'chebyshev_outgain'.kr(0.5)
        ],
        info:'++chebyshev'
    )
}
)