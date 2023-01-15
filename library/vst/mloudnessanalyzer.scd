(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'Gain (Settings)', 'mloudnessanalyzer_gainsettings'.kr(0.5),
			'Limit (Settings)', 'mloudnessanalyzer_limitsettings'.kr(0.050000000745058),
			'Mode (Settings)', 'mloudnessanalyzer_modesettings'.kr(0.5),
			'Offset (Settings)', 'mloudnessanalyzer_offsetsetting'.kr(0.5),
			//'Previous(PresetTrigger)', 'mloudnessanalyzer_previousprese'.kr(0.0),
			'Reset mode (Settings)', 'mloudnessanalyzer_resetmodesett'.kr(0.0),
			'Target (Settings)', 'mloudnessanalyzer_targetsetting'.kr(0.61666667461395),
			//'next (Preset trigger)', 'mloudnessanalyzer_nextpresettri'.kr(0.0),
		],
		info:'MLoudnessAnalyzer'
    )
}
)