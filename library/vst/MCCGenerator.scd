(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'AutomaValue(Modul-Mod1)', 'mccgenerator_automavaluemodulmo'.kr(0.5),
			'AutomaValue(Modul-Mod2)', 'mccgenerator_automavaluemodulmo'.kr(0.5),
			'AutomaValue(Modul-Mod3)', 'mccgenerator_automavaluemodulmo'.kr(0.5),
			'AutomaValue(Modul-Mod4)', 'mccgenerator_automavaluemodulmo'.kr(0.5),
			'AutomaValue(Modul-Mod5)', 'mccgenerator_automavaluemodulmo'.kr(0.5),
			'AutomaValue(Modul-Mod6)', 'mccgenerator_automavaluemodulmo'.kr(0.5),
			'AutomaValue(Modul-Mod7)', 'mccgenerator_automavaluemodulmo'.kr(0.5),
			'AutomaValue(Modul-Mod8)', 'mccgenerator_automavaluemodulmo'.kr(0.5),
			'CC 1 (CC 1)', 'mccgenerator_cc1cc1'.kr(1.0),
			'CC 2 (CC 2)', 'mccgenerator_cc2cc2'.kr(0.0),
			'CC 3 (CC 3)', 'mccgenerator_cc3cc3'.kr(0.0),
			'CC 4 (CC 4)', 'mccgenerator_cc4cc4'.kr(0.0),
			'CC 5 (CC 5)', 'mccgenerator_cc5cc5'.kr(0.0),
			'CC 6 (CC 6)', 'mccgenerator_cc6cc6'.kr(0.0),
			'CC 7 (CC 7)', 'mccgenerator_cc7cc7'.kr(0.0),
			'CC 8 (CC 8)', 'mccgenerator_cc8cc8'.kr(0.0),
			'Channel (CC 1)', 'mccgenerator_channelcc1'.kr(0.0),
			'Channel (CC 2)', 'mccgenerator_channelcc2'.kr(0.0),
			'Channel (CC 3)', 'mccgenerator_channelcc3'.kr(0.0),
			'Channel (CC 4)', 'mccgenerator_channelcc4'.kr(0.0),
			'Channel (CC 5)', 'mccgenerator_channelcc5'.kr(0.0),
			'Channel (CC 6)', 'mccgenerator_channelcc6'.kr(0.0),
			'Channel (CC 7)', 'mccgenerator_channelcc7'.kr(0.0),
			'Channel (CC 8)', 'mccgenerator_channelcc8'.kr(0.0),
			'Controller (CC 1)', 'mccgenerator_controllercc1'.kr(0.0077519379556179),
			'Controller (CC 2)', 'mccgenerator_controllercc2'.kr(0.015503875911236),
			'Controller (CC 3)', 'mccgenerator_controllercc3'.kr(0.023255813866854),
			'Controller (CC 4)', 'mccgenerator_controllercc4'.kr(0.031007751822472),
			'Controller (CC 5)', 'mccgenerator_controllercc5'.kr(0.03875968977809),
			'Controller (CC 6)', 'mccgenerator_controllercc6'.kr(0.046511627733707),
			'Controller (CC 7)', 'mccgenerator_controllercc7'.kr(0.054263565689325),
			'Controller (CC 8)', 'mccgenerator_controllercc8'.kr(0.062015503644943),
			'High accuracy', 'mccgenerator_highaccuracy'.kr(1.0),
			'Param 1', 'mccgenerator_param1'.kr(0.5),
			'Param 2', 'mccgenerator_param2'.kr(0.5),
			'Param 3', 'mccgenerator_param3'.kr(0.5),
			'Param 4', 'mccgenerator_param4'.kr(0.5),
			//'Previous(PresetTrigger)', 'mccgenerator_previouspresettrig'.kr(0.0),
			'Value (CC 1)', 'mccgenerator_valuecc1'.kr(0.0),
			'Value (CC 2)', 'mccgenerator_valuecc2'.kr(0.0),
			'Value (CC 3)', 'mccgenerator_valuecc3'.kr(0.0),
			'Value (CC 4)', 'mccgenerator_valuecc4'.kr(0.0),
			'Value (CC 5)', 'mccgenerator_valuecc5'.kr(0.0),
			'Value (CC 6)', 'mccgenerator_valuecc6'.kr(0.0),
			'Value (CC 7)', 'mccgenerator_valuecc7'.kr(0.0),
			'Value (CC 8)', 'mccgenerator_valuecc8'.kr(0.0),
			//'next (Preset trigger)', 'mccgenerator_nextpresettrigger'.kr(0.0),
		],
		info:'MCCGenerator'
    )
}
)