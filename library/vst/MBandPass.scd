(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'AutomaValue(Modul-Mod1)', 'mbandpass_automavaluemodulmod1'.kr(0.5),
			'AutomaValue(Modul-Mod2)', 'mbandpass_automavaluemodulmod2'.kr(0.5),
			'Dry/Wet', 'mbandpass_drywet'.kr(1.0),
			'Frequenc(High-paFilter)', 'mbandpass_frequenchighpafilter'.kr(0.0),
			'Frequenc(Low-pasFilter)', 'mbandpass_frequenclowpasfilter'.kr(1.0),
			'Gain', 'mbandpass_gain'.kr(0.5),
			'High-pFilter(High-Filter', 'mbandpass_highpfilterhighfilter'.kr(0.0),
			'Low-paFilter(Low-pFilter', 'mbandpass_lowpafilterlowpfilter'.kr(0.0),
			'Param 1', 'mbandpass_param1'.kr(0.5),
			'Param 2', 'mbandpass_param2'.kr(0.5),
			//'Previous(PresetTrigger)', 'mbandpass_previouspresettrigger'.kr(0.0),
			'Q (High-pass filter)', 'mbandpass_qhighpassfilter'.kr(0.28474971652031),
			'Q (Low-pass filter)', 'mbandpass_qlowpassfilter'.kr(0.28474971652031),
			'Slope (High-pass filter)', 'mbandpass_slopehighpassfilter'.kr(0.18181818723679),
			'Slope (Low-pass filter)', 'mbandpass_slopelowpassfilter'.kr(0.18181818723679),
			//'next (Preset trigger)', 'mbandpass_nextpresettrigger'.kr(0.0),
		],
		info:'MBandPass'
    )
}
)