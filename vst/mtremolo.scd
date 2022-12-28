(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'Depth', 'mtremolo_depth'.kr(0.5),
			'Invert tremolo phase', 'mtremolo_inverttremolophase'.kr(0.0),
			'LFO override', 'mtremolo_lfooverride'.kr(0.0),
			'Length (Synchronization)', 'mtremolo_lengthsynchronization'.kr(0.64285713434219),
			'Param 1', 'mtremolo_param1'.kr(0.5),
			'Param 2', 'mtremolo_param2'.kr(0.5),
			'Param 3', 'mtremolo_param3'.kr(0.5),
			'Param 4', 'mtremolo_param4'.kr(0.5),
			'Phase (Synchronization)', 'mtremolo_phasesynchronization'.kr(0.25),
			'Phase difference', 'mtremolo_phasedifference'.kr(0.5),
			//'Previous(PresetTrigger)', 'mtremolo_previouspresettrigger'.kr(0.0),
			'Rate', 'mtremolo_rate'.kr(0.78825700283051),
			'Synchronizat(Synchroniza', 'mtremolo_synchronizatsynchroniz'.kr(0.0),
			'Type (Synchronization)', 'mtremolo_typesynchronization'.kr(0.0),
			//'next (Preset trigger)', 'mtremolo_nextpresettrigger'.kr(0.0),
		],
		info:'MTremolo'
    )
}
)