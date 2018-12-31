/////////////////////////////////
// synth

MIDIClient.init;
m = MIDIOut(0);


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

Pbindef(\midi_pattern).play
Pbindef(\midi_pattern).stop

~midi_pairs.play
~midi_pairs.stop

Event








