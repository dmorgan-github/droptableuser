(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'Max frequency (Detector)', 'moscilloscope_maxfrequencydetec'.kr(0.56632333993912),
			'Min frequency (Detector)', 'moscilloscope_minfrequencydetec'.kr(0.0),
		],
		info:'MOscilloscope'
    )
}
)