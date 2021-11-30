(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'Depth', 'mvibrato_depth'.kr(0.40000000596046),
			'Invert tremolo phase', 'mvibrato_inverttremolophase'.kr(0.0),
			'LFO override', 'mvibrato_lfooverride'.kr(0.0),
			'Length (Synchronization)', 'mvibrato_lengthsynchronization'.kr(0.64285713434219),
			'Param 1', 'mvibrato_param1'.kr(0.5),
			'Param 2', 'mvibrato_param2'.kr(0.5),
			'Param 3', 'mvibrato_param3'.kr(0.5),
			'Param 4', 'mvibrato_param4'.kr(0.5),
			'Phase (Synchronization)', 'mvibrato_phasesynchronization'.kr(0.25),
			'Phase difference', 'mvibrato_phasedifference'.kr(0.5),
			//'Previous(PresetTrigger)', 'mvibrato_previouspresettrigger'.kr(0.0),
			'Rate', 'mvibrato_rate'.kr(0.78825700283051),
			'SimulateRealisticShapes', 'mvibrato_simulaterealisticshape'.kr(0.0),
			'Synchronizat(Synchroniza', 'mvibrato_synchronizatsynchroniz'.kr(0.0),
			'Tremolo', 'mvibrato_tremolo'.kr(0.0),
			'Tremolo phase', 'mvibrato_tremolophase'.kr(0.0),
			'Type (Synchronization)', 'mvibrato_typesynchronization'.kr(0.0),
			//'next (Preset trigger)', 'mvibrato_nextpresettrigger'.kr(0.0),
		],
		info:'MVibrato'
    )
}
)