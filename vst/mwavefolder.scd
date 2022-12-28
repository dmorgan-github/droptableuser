(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'Automatic gain control', 'mwavefolder_automaticgaincontro'.kr(1.0),
			'Character', 'mwavefolder_character'.kr(0.5),
			'DC blocker', 'mwavefolder_dcblocker'.kr(1.0),
			'Drive', 'mwavefolder_drive'.kr(0.23076923191547),
			'Dry/Wet', 'mwavefolder_drywet'.kr(1.0),
			'Gain Out', 'mwavefolder_gainout'.kr(0.5),
			'Non-linearity', 'mwavefolder_nonlinearity'.kr(0.0),
			'Oversampling', 'mwavefolder_oversampling'.kr(0.0),
			'Post LP', 'mwavefolder_postlp'.kr(1.0),
			'Pre HP', 'mwavefolder_prehp'.kr(0.0),
			'Pre LP', 'mwavefolder_prelp'.kr(1.0),
			//'Previous(PresetTrigger)', 'mwavefolder_previouspresettrigg'.kr(0.0),
			'Symmetry', 'mwavefolder_symmetry'.kr(0.5),
			//'next (Preset trigger)', 'mwavefolder_nextpresettrigger'.kr(0.0),
		],
		info:'MWaveFolder'
    )
}
)