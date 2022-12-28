(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'Blinking (Visualisation)', 'mmetronome_blinkingvisualisatio'.kr(0.20000000298023),
			'Frequency (Sound)', 'mmetronome_frequencysound'.kr(0.44747424125671),
			'Gain 1st (Sound)', 'mmetronome_gain1stsound'.kr(0.5),
			'Indicator(Visualisation)', 'mmetronome_indicatorvisualisati'.kr(1.0),
			'Length (Sound)', 'mmetronome_lengthsound'.kr(0.31622776389122),
			'Movement (Visualisation)', 'mmetronome_movementvisualisatio'.kr(0.5),
			'Param 1', 'mmetronome_param1'.kr(0.5),
			'Param 2', 'mmetronome_param2'.kr(0.5),
			'Param 3', 'mmetronome_param3'.kr(0.5),
			'Param 4', 'mmetronome_param4'.kr(0.5),
			'Pitch (Sound)', 'mmetronome_pitchsound'.kr(0.5),
			'Pitch 1st (Sound)', 'mmetronome_pitch1stsound'.kr(0.64583331346512),
			//'Previous(PresetTrigger)', 'mmetronome_previouspresettrigge'.kr(0.0),
			'Sound (Sound)', 'mmetronome_soundsound'.kr(1.0),
			'Speed', 'mmetronome_speed'.kr(0.5),
			'Tone (Sound)', 'mmetronome_tonesound'.kr(0.0),
			'Tone first (Sound)', 'mmetronome_tonefirstsound'.kr(0.0),
			'Visualisatio(Visualisati', 'mmetronome_visualisatiovisualis'.kr(1.0),
			'Volume (Sound)', 'mmetronome_volumesound'.kr(0.31622776389122),
			'Which is first (Sound)', 'mmetronome_whichisfirstsound'.kr(0.0),
			'Width (Sound)', 'mmetronome_widthsound'.kr(0.0),
			//'next (Preset trigger)', 'mmetronome_nextpresettrigger'.kr(0.0),
		],
		info:'MMetronome'
    )
}
)