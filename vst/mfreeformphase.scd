(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'Depth', 'mfreeformphase_depth'.kr(0.31622776389122),
			//'Previous(PresetTrigger)', 'mfreeformphase_previouspresettr'.kr(0.0),
			'Quality', 'mfreeformphase_quality'.kr(0.5),
			//'next (Preset trigger)', 'mfreeformphase_nextpresettrigge'.kr(0.0),
		],
		info:'MFreeformPhase'
    )
}
)