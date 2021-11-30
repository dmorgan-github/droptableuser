(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'Delay', 'mstereoexpander_delay'.kr(0.20000000298023),
			'Delay depth', 'mstereoexpander_delaydepth'.kr(0.0),
			'Depth', 'mstereoexpander_depth'.kr(0.5),
			'High pass frequency', 'mstereoexpander_highpassfrequen'.kr(0.0),
			'Low pass frequency', 'mstereoexpander_lowpassfrequenc'.kr(1.0),
			'Param 1', 'mstereoexpander_param1'.kr(0.5),
			'Param 2', 'mstereoexpander_param2'.kr(0.5),
			'Param 3', 'mstereoexpander_param3'.kr(0.5),
			'Param 4', 'mstereoexpander_param4'.kr(0.5),
			//'Previous(PresetTrigger)', 'mstereoexpander_previouspresett'.kr(0.0),
			'Resonance', 'mstereoexpander_resonance'.kr(0.0),
			//'next (Preset trigger)', 'mstereoexpander_nextpresettrigg'.kr(0.0),
		],
		info:'MStereoExpander'
    )
}
)