(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'BPS', 'mrecorder_bps'.kr(1.0),
			'Cancel', 'mrecorder_cancel'.kr(0.0),
			'FadeIn/out(Post-processi', 'mrecorder_fadeinoutpostprocessi'.kr(0.0),
			'Mute when recording', 'mrecorder_mutewhenrecording'.kr(0.0),
			'Normalize(Post-processin', 'mrecorder_normalizepostprocessi'.kr(0.0),
			'Pause', 'mrecorder_pause'.kr(0.0),
			'PauseWhenPlaybacDisable', 'mrecorder_pausewhenplaybacdisab'.kr(0.0),
			'Post-process(Post-proces', 'mrecorder_postprocesspostproces'.kr(0.0),
			//'Previous(PresetTrigger)', 'mrecorder_previouspresettrigger'.kr(0.0),
			'Record', 'mrecorder_record'.kr(0.0),
			'SynchronizeAllInstances', 'mrecorder_synchronizeallinstanc'.kr(0.0),
			'TrimThreshold(Post-proce', 'mrecorder_trimthresholdpostproc'.kr(0.0),
			//'next (Preset trigger)', 'mrecorder_nextpresettrigger'.kr(0.0),
		],
		info:'MRecorder'
    )
}
)