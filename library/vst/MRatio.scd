(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'AutomaValue(Modul-Mod1)', 'mratio_automavaluemodulmod1'.kr(0.5),
			'AutomaValue(Modul-Mod2)', 'mratio_automavaluemodulmod2'.kr(0.5),
			'Gain', 'mratio_gain'.kr(0.5),
			'Mode', 'mratio_mode'.kr(0.28571429848671),
			'Panorama', 'mratio_panorama'.kr(0.5),
			'Param 1', 'mratio_param1'.kr(0.5),
			'Param 2', 'mratio_param2'.kr(0.5),
			//'Previous(PresetTrigger)', 'mratio_previouspresettrigger'.kr(0.0),
			'Ratio', 'mratio_ratio'.kr(0.5),
			'Volume', 'mratio_volume'.kr(1.0),
			//'next (Preset trigger)', 'mratio_nextpresettrigger'.kr(0.0),
		],
		info:'MRatio'
    )
}
)