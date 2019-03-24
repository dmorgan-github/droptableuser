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
	\chan, 0,
	\delta, 0.25,
	\legato, 0.1,
	\scale, Scale.dorian,
	\octave, Pbjorklund(3, 8, inf).collect({arg val; if (val == 1){6}{5}}),
	\degree, Ppatlace([Pseq([0, 7], inf), Pseq([1,3,2,5], inf)], inf)
);
)

Pbindef(\midi_pattern).play;
Pbindef(\midi_pattern).stop;

SimpleMIDIFile

ServerMeter.new(s, 8, 8);

(
Pbindef(\midi_pattern2,

	\type, \midi,
	\midicmd, \noteOn,
	\midiout, m,
	\chan, 1,
	\delta, 0.25,
	\legato, 0.5,
	\scale, Scale.dorian,
	\octave, Pbjorklund(5, 9, inf).collect({arg val; if (val == 1){5}{4}}),
	\degree, Ppatlace([Pseq([0, 7], inf), Pseq([1,3,2,6,5], inf)], inf, 1)
);
)

Pbindef(\midi_pattern2).play;
Pbindef(\midi_pattern2).stop;




