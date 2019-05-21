/////////////////////////////////
// synth

MIDIClient.init;
m = MIDIOut(0);

MIDIClient.list

Pdef(\midi_pattern).clear;

(
Pdef(\midi_pattern,
	Pbind(
		\type, \midi,
		\midicmd, \noteOn,
		\midiout, m,
		\chan, 0,
		\delta, 0.25,
		\legato, 0.01,
		\xy, Ptuple([
			[1, 0, 0, 8],
			[0, 3, 6, 0],
			[0, 4, 5, 0],
			[2, 0, 0, 7]
		], inf).collect(`_),
		\x, Pseries(0, 1).stutter(8),
		\y, Pseries(0, 1).stutter(2),
		\foo, Pfunc({arg evt;
			var x = evt[\x];
			var y = evt[\y];
			var xy = evt[\xy];
			var val = xy.next.wrapAt(y).next.wrapAt(x).next;
			val;
		}),
		\scale, Scale.dorian.tuning_(\just),
		\octave, Pbjorklund(3, 8, inf).collect({arg val; if (val == 1){6}{5}}),
		\degree, Pkey(\foo),//Pwhite(0, 4),
		\pb, Pbjorklund(3, 8),
		\amp, 0.dbamp * Pif(Pfunc({arg evt; evt[\pb] == 1}), 1, 0.7),
	)
)
)

Pdef(\midi_pattern).play;
Pdef(\midi_pattern).stop;

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




