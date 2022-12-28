(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'Depth', 'mautopan_depth'.kr(0.5),
			'LFO override', 'mautopan_lfooverride'.kr(0.0),
			'Length (Synchronization)', 'mautopan_lengthsynchronization'.kr(0.64285713434219),
			'Pan law', 'mautopan_panlaw'.kr(0.75),
			'Param 1', 'mautopan_param1'.kr(0.5),
			'Param 2', 'mautopan_param2'.kr(0.5),
			'Param 3', 'mautopan_param3'.kr(0.5),
			'Param 4', 'mautopan_param4'.kr(0.5),
			'Phase (Synchronization)', 'mautopan_phasesynchronization'.kr(0.25),
			//'Previous(PresetTrigger)', 'mautopan_previouspresettrigger'.kr(0.0),
			'Rate', 'mautopan_rate'.kr(0.78825700283051),
			'Synchronizat(Synchroniza', 'mautopan_synchronizatsynchroniz'.kr(0.0),
			'Type (Synchronization)', 'mautopan_typesynchronization'.kr(0.0),
			//'next (Preset trigger)', 'mautopan_nextpresettrigger'.kr(0.0),
		],
		info:'MAutopan'
    )
}
)