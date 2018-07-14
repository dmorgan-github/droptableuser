/////////////////////////////////
// synth

MIDIClient.init;
m = MIDIOut(0);


(
~midi_pairs = Pbindef(\midi_pairs,

	\type, \midi, \midicmd, \noteOn, \midiout, m, \chan, 1,

	\delta, 4,

	\curve, [-4, 4],
	\sus, [0,0],
	\atk, [0.01,0.01],
	\pan, [-0.5, 0.5],
	\amp, 0.08,

	\degree, Pbrown(0, 4, 1, inf),

	\vrate, [4,5],
	\vrateVar, [0.5, 0.1],
	\vdepthVar, [0.5, 0.3],

	\mtranspose, 0,
	\gtranspose, 0,
	\ctranspose, 0,
	\root, 0,
	\scale, Scale.kumoi,
	\stepsPerOctave, 12,

	\octave2, Prand([4, 5], inf),
	\degree2, Pkey(\degree) + (Prand([2, 3], inf) * Prand([-1,1], inf)),

	\f1, Pfunc({arg evt;
		var note = (evt[\degree] + evt[\mtranspose]).degreeToKey(evt[\scale], evt[\stepsPerOctave]);
		var midinote = ((note + evt[\gtranspose] + evt[\root])/ evt[\stepsPerOctave] + evt[\octave]) * 12.0;
		var freq = (midinote + evt[\ctranspose]).midicps;
		freq;
	}),
	\f2, Pfunc({arg evt;
		var note = (evt[\degree2] + evt[\mtranspose]).degreeToKey(evt[\scale], evt[\stepsPerOctave]);
		var midinote = ((note + evt[\gtranspose] + evt[\root])/ evt[\stepsPerOctave] + evt[\octave2]) * 12.0;
		var freq = (midinote + evt[\ctranspose]).midicps;
		freq;
	}),
	\freq, Ptuple([ Pkey(\f1), Pkey(\f2)], inf),

	\midinote, Pkey(\freq).cpsmidi
);
)

~midi_pairs.play








