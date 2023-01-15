(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'Character', 'mfreqshifter_character'.kr(0.0),
			'Count (Synchronization)', 'mfreqshifter_countsynchronizati'.kr(0.0),
			'Delay', 'mfreqshifter_delay'.kr(0.10000000149012),
			'Dry/Wet', 'mfreqshifter_drywet'.kr(1.0),
			'Feedback', 'mfreqshifter_feedback'.kr(0.0),
			'Length (Synchronization)', 'mfreqshifter_lengthsynchronizat'.kr(0.64285713434219),
			'Param 1', 'mfreqshifter_param1'.kr(0.5),
			'Param 2', 'mfreqshifter_param2'.kr(0.5),
			'Param 3', 'mfreqshifter_param3'.kr(0.5),
			'Param 4', 'mfreqshifter_param4'.kr(0.5),
			'Prefiltering', 'mfreqshifter_prefiltering'.kr(1.0),
			//'Previous(PresetTrigger)', 'mfreqshifter_previouspresettrig'.kr(0.0),
			'Reserved(Synchronization', 'mfreqshifter_reservedsynchroniz'.kr(0.0),
			'Shift', 'mfreqshifter_shift'.kr(0.5),
			'Synchronizat(Synchroniza', 'mfreqshifter_synchronizatsynchr'.kr(0.0),
			'Type (Synchronization)', 'mfreqshifter_typesynchronizatio'.kr(0.0),
			'Width', 'mfreqshifter_width'.kr(0.75),
			//'next (Preset trigger)', 'mfreqshifter_nextpresettrigger'.kr(0.0),
		],
		info:'MFreqShifter'
    )
}
)