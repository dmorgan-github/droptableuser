(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'Dry/Wet', 'mphaser_drywet'.kr(0.40000000596046),
			'Feedback', 'mphaser_feedback'.kr(0.69999998807907),
			'Invert feedback polarity', 'mphaser_invertfeedbackpolarity'.kr(0.0),
			'LFO override', 'mphaser_lfooverride'.kr(0.0),
			'Length (Synchronization)', 'mphaser_lengthsynchronization'.kr(0.64285713434219),
			'Max frequency', 'mphaser_maxfrequency'.kr(0.66666668653488),
			'Min frequency', 'mphaser_minfrequency'.kr(0.43367666006088),
			'Mode', 'mphaser_mode'.kr(0.030303031206131),
			'Param 1', 'mphaser_param1'.kr(0.5),
			'Param 2', 'mphaser_param2'.kr(0.5),
			'Param 3', 'mphaser_param3'.kr(0.5),
			'Param 4', 'mphaser_param4'.kr(0.5),
			'Phase (Synchronization)', 'mphaser_phasesynchronization'.kr(0.25),
			'Phase difference', 'mphaser_phasedifference'.kr(0.75),
			//'Previous(PresetTrigger)', 'mphaser_previouspresettrigger'.kr(0.0),
			'Rate', 'mphaser_rate'.kr(0.6970642209053),
			'Saturation', 'mphaser_saturation'.kr(0.0),
			'Shape mode', 'mphaser_shapemode'.kr(0.0),
			'Synchronizat(Synchroniza', 'mphaser_synchronizatsynchroniza'.kr(0.0),
			'Type (Synchronization)', 'mphaser_typesynchronization'.kr(0.0),
			//'next (Preset trigger)', 'mphaser_nextpresettrigger'.kr(0.0),
		],
		info:'MPhaser'
    )
}
)