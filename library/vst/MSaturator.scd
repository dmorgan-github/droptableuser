(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'2nd (Harmonics)', 'msaturator_2ndharmonics'.kr(0.5),
			'3rd (Harmonics)', 'msaturator_3rdharmonics'.kr(0.5),
			'4th (Harmonics)', 'msaturator_4thharmonics'.kr(0.5),
			'5th (Harmonics)', 'msaturator_5thharmonics'.kr(0.5),
			'Attack (Compander)', 'msaturator_attackcompander'.kr(0.31622776389122),
			'Compander (Compander)', 'msaturator_compandercompander'.kr(0.0),
			'Dry/Wet', 'msaturator_drywet'.kr(1.0),
			'Dry/Wet (Compander)', 'msaturator_drywetcompander'.kr(1.0),
			'Enable clipping', 'msaturator_enableclipping'.kr(1.0),
			'Even harmonics', 'msaturator_evenharmonics'.kr(0.10000000149012),
			'Gain', 'msaturator_gain'.kr(0.5),
			'Gain (Harmonics)', 'msaturator_gainharmonics'.kr(0.5),
			'Harmonics (Harmonics)', 'msaturator_harmonicsharmonics'.kr(0.0),
			'Mode', 'msaturator_mode'.kr(0.0),
			'Output (Compander)', 'msaturator_outputcompander'.kr(0.5),
			'Output gain', 'msaturator_outputgain'.kr(0.5),
			//'Previous(PresetTrigger)', 'msaturator_previouspresettrigge'.kr(0.0),
			'Ratio (Compander)', 'msaturator_ratiocompander'.kr(1.0),
			'Release (Compander)', 'msaturator_releasecompander'.kr(0.31544211506844),
			'Threshold', 'msaturator_threshold'.kr(0.0),
			'Threshold (Compander)', 'msaturator_thresholdcompander'.kr(0.090909093618393),
			//'next (Preset trigger)', 'msaturator_nextpresettrigger'.kr(0.0),
		],
		info:'MSaturator'
    )
}
)