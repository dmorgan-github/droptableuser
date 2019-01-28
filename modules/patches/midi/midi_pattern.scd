/////////////////////////////////
// synth

MIDIClient.init;
m = MIDIOut(0);

MIDIClient.list

(
Pbindef(\midi_pattern,

	\type, \midi,
	\midicmd, \noteOn,
	\midiout, m,
	\chan, 1,
	\delta, 0.25,
	\scale, Scale.dorian,
	\octave, Prand([5], inf),
	\degree, Pxrand((0..7), inf)
);
)


~midi_pairs.play
~midi_pairs.stop



