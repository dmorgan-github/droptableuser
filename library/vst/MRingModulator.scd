(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'Depth (Oscillator 1)', 'mringmodulator_depthoscillator1'.kr(1.0),
			'Depth (Oscillator 2)', 'mringmodulator_depthoscillator2'.kr(1.0),
			'Frequency (Oscillator 1)', 'mringmodulator_frequencyoscilla'.kr(0.13264666497707),
			'Frequency (Oscillator 2)', 'mringmodulator_frequencyoscilla'.kr(0.13264666497707),
			'Modulate oscillators', 'mringmodulator_modulateoscillat'.kr(0.0),
			'Oscillator1(Oscillator1)', 'mringmodulator_oscillator1oscil'.kr(1.0),
			'Oscillator2(Oscillator2)', 'mringmodulator_oscillator2oscil'.kr(0.0),
			'Param 1', 'mringmodulator_param1'.kr(0.5),
			'Param 2', 'mringmodulator_param2'.kr(0.5),
			'Param 3', 'mringmodulator_param3'.kr(0.5),
			'Param 4', 'mringmodulator_param4'.kr(0.5),
			'Phase (Oscillator 1)', 'mringmodulator_phaseoscillator1'.kr(0.10000000149012),
			'Phase (Oscillator 2)', 'mringmodulator_phaseoscillator2'.kr(0.10000000149012),
			//'Previous(PresetTrigger)', 'mringmodulator_previouspresettr'.kr(0.0),
			'Side-chain(Oscillator1)', 'mringmodulator_sidechainoscilla'.kr(0.0),
			'Side-chain(Oscillator2)', 'mringmodulator_sidechainoscilla'.kr(0.0),
			//'next (Preset trigger)', 'mringmodulator_nextpresettrigge'.kr(0.0),
		],
		info:'MRingModulator'
    )
}
)