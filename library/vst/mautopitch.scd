(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'A', 'mautopitch_a'.kr(1.0),
			'A#', 'mautopitch_a'.kr(1.0),
			'B', 'mautopitch_b'.kr(1.0),
			'BaseFreque(AutomTuning', 'mautopitch_basefrequeautomtunin'.kr(0.5),
			'C', 'mautopitch_c'.kr(1.0),
			'C#', 'mautopitch_c'.kr(1.0),
			'D', 'mautopitch_d'.kr(1.0),
			'D#', 'mautopitch_d'.kr(1.0),
			'Depth (Automatic tuning)', 'mautopitch_depthautomatictuning'.kr(0.5),
			'Detune(AutomaticTuning)', 'mautopitch_detuneautomatictunin'.kr(0.5),
			'Dry/Wet (Effects)', 'mautopitch_dryweteffects'.kr(1.0),
			'E', 'mautopitch_e'.kr(1.0),
			'F', 'mautopitch_f'.kr(1.0),
			'F#', 'mautopitch_f'.kr(1.0),
			'Formant shift (Effects)', 'mautopitch_formantshifteffects'.kr(0.5),
			'G', 'mautopitch_g'.kr(1.0),
			'G#', 'mautopitch_g'.kr(1.0),
			'Keep formants (Effects)', 'mautopitch_keepformantseffects'.kr(1.0),
			'Max frequency (Detector)', 'mautopitch_maxfrequencydetector'.kr(0.56632333993912),
			'Min frequency (Detector)', 'mautopitch_minfrequencydetector'.kr(0.0),
			//'Previous(PresetTrigger)', 'mautopitch_previouspresettrigge'.kr(0.0),
			'Speed (Automatic tuning)', 'mautopitch_speedautomatictuning'.kr(0.5),
			'Stabilization (Detector)', 'mautopitch_stabilizationdetecto'.kr(0.0),
			'Threshold (Detector)', 'mautopitch_thresholddetector'.kr(0.0),
			'Width (Effects)', 'mautopitch_widtheffects'.kr(0.5),
			//'next (Preset trigger)', 'mautopitch_nextpresettrigger'.kr(0.0),
		],
		info:'MAutoPitch'
    )
}
)