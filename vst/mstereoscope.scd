(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'Mode', 'mstereoscope_mode'.kr(0.0),
			'Output gain', 'mstereoscope_outputgain'.kr(0.5),
		],
		info:'MStereoScope'
    )
}
)