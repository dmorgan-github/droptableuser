(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'Dry/Wet', 'mconvolutionez_drywet'.kr(1.0),
			'File(ImpulsResponsFile)', 'mconvolutionez_fileimpulsrespon'.kr(0.52727270126343),
			'High-pass', 'mconvolutionez_highpass'.kr(0.0),
			'Low-pass', 'mconvolutionez_lowpass'.kr(1.0),
			'Normalize IR loudness', 'mconvolutionez_normalizeirloudn'.kr(1.0),
			'Predelay', 'mconvolutionez_predelay'.kr(0.0),
			//'Previous(PresetTrigger)', 'mconvolutionez_previouspresettr'.kr(0.0),
			'Widening', 'mconvolutionez_widening'.kr(0.33333334326744),
			//'next (Preset trigger)', 'mconvolutionez_nextpresettrigge'.kr(0.0),
		],
		info:'MConvolutionEZ'
    )
}
)