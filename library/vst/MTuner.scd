(
synth: {|in|
    VSTPlugin.ar(in, 2,
        params: [
			'AutoSwitToNormTune(Adv', 'mtuner_autoswittonormtuneadv'.kr(0.0),
			'Base frequency', 'mtuner_basefrequency'.kr(0.5),
			'DetecteCents(MIDIOutput)', 'mtuner_detectecentsmidioutput'.kr(0.5),
			'DetectedNote(MIDIOutput)', 'mtuner_detectednotemidioutput'.kr(0.0),
			'EmitPitch-be(MIDIOutput)', 'mtuner_emitpitchbemidioutput'.kr(0.0),
			'HarmonicDeviatio(Advance', 'mtuner_harmonicdeviatioadvance'.kr(0.49621683359146),
			'Harmonics (Advanced)', 'mtuner_harmonicsadvanced'.kr(0.60000002384186),
			'High-accuracy (Tuner)', 'mtuner_highaccuracytuner'.kr(0.0),
			'MIDIOutput(MIDIOutput)', 'mtuner_midioutputmidioutput'.kr(0.0),
			'Max frequency (Tuner)', 'mtuner_maxfrequencytuner'.kr(0.56632333993912),
			'Min frequency (Tuner)', 'mtuner_minfrequencytuner'.kr(0.0),
			'Note 1 (PolyTuner)', 'mtuner_note1polytuner'.kr(0.0),
			'Note 2 (PolyTuner)', 'mtuner_note2polytuner'.kr(0.3203125),
			'Note 3 (PolyTuner)', 'mtuner_note3polytuner'.kr(0.359375),
			'Note 4 (PolyTuner)', 'mtuner_note4polytuner'.kr(0.3984375),
			'Note 5 (PolyTuner)', 'mtuner_note5polytuner'.kr(0.4375),
			'Note 6 (PolyTuner)', 'mtuner_note6polytuner'.kr(0.46875),
			'Note 7 (PolyTuner)', 'mtuner_note7polytuner'.kr(0.5078125),
			'Note 8 (PolyTuner)', 'mtuner_note8polytuner'.kr(0.0),
			'NoteThreshold(Advanced)', 'mtuner_notethresholdadvanced'.kr(0.30151134729385),
			//'Previous(PresetTrigger)', 'mtuner_previouspresettrigger'.kr(0.0),
			'Range Off (MIDI output)', 'mtuner_rangeoffmidioutput'.kr(0.83333331346512),
			'Stabilization (Tuner)', 'mtuner_stabilizationtuner'.kr(0.31622776389122),
			'Threshold (Advanced)', 'mtuner_thresholdadvanced'.kr(0.17508120834827),
			'ThresholdOn(MIDIOutput)', 'mtuner_thresholdonmidioutput'.kr(0.10000000149012),
			//'next (Preset trigger)', 'mtuner_nextpresettrigger'.kr(0.0),
		],
		info:'MTuner'
    )
}
)