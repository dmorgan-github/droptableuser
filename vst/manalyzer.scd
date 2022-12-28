(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'AveragLength(BasicSettin', 'manalyzer_averaglengthbasicsett'.kr(0.03999999910593),
			//'Previous(PresetTrigger)', 'manalyzer_previouspresettrigger'.kr(0.0),
			'Smoothnes(BasicSettings)', 'manalyzer_smoothnesbasicsetting'.kr(0.050000000745058),
			//'next (Preset trigger)', 'manalyzer_nextpresettrigger'.kr(0.0),
		],
		info:'MAnalyzer'
    )
}
)