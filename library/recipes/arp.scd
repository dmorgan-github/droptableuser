Pbind(
	\chords, [
		[-1, 1, 3],
		[0, 3, 4]
	].pseq.stutter(16),

	\degree, Prout({|inval|
		var lastchord = [];
		var chord = inval[\chords];
		var arp = Pseries(0, 1).fold(0, chord.size-1).asStream;
		inf.do({|i|
			var degree;
			var chord = inval[\chords];
			if (chord != lastchord) {
				arp = Pseries(0, 1).fold(0, chord.size-1).asStream;
				lastchord = chord;
			};
			degree = chord[arp.next];
			inval = degree.embedInStream(inval);
			inval;
		})
	})
)


Parp(\chords, {|chord| Pwalk(chord, Pwalk(chord, [1], [1, -2].pseq, (chord/2).floor })