(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'Delay', 'mflanger_delay'.kr(0.0),
			'Depth', 'mflanger_depth'.kr(0.75),
			'Feedback', 'mflanger_feedback'.kr(0.5),
			'Jet', 'mflanger_jet'.kr(0.5),
			'Jet phase', 'mflanger_jetphase'.kr(0.0),
			'LFO override', 'mflanger_lfooverride'.kr(0.0),
			'Length (Synchronization)', 'mflanger_lengthsynchronization'.kr(0.64285713434219),
			'Max frequency', 'mflanger_maxfrequency'.kr(1.0),
			'Min frequency', 'mflanger_minfrequency'.kr(0.1003433316946),
			'Min range', 'mflanger_minrange'.kr(0.0),
			'Mode', 'mflanger_mode'.kr(0.0),
			'Param 1', 'mflanger_param1'.kr(0.5),
			'Param 2', 'mflanger_param2'.kr(0.5),
			'Param 3', 'mflanger_param3'.kr(0.5),
			'Param 4', 'mflanger_param4'.kr(0.5),
			'Phase (Synchronization)', 'mflanger_phasesynchronization'.kr(0.25),
			'Phase difference', 'mflanger_phasedifference'.kr(0.5),
			//'Previous(PresetTrigger)', 'mflanger_previouspresettrigger'.kr(0.0),
			'Range', 'mflanger_range'.kr(0.28284272551537),
			'Rate', 'mflanger_rate'.kr(0.39412850141525),
			'Saturation', 'mflanger_saturation'.kr(0.0),
			'Synchronizat(Synchroniza', 'mflanger_synchronizatsynchroniz'.kr(0.0),
			'Type (Synchronization)', 'mflanger_typesynchronization'.kr(0.0),
			//'next (Preset trigger)', 'mflanger_nextpresettrigger'.kr(0.0),
		],
		info:'MFlanger'
    )
}
)