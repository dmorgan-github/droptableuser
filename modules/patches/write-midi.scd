(
// create a MIDI file
m = SimpleMIDIFile("~/output.mid");
m.init1;
m.timeMode_( \seconds ); // correct timeMode

// add some random Notes
((0,(1/8)..5)).do({ |starttime|
	m.addNote( 36 + 50.rand, 32 + 96.rand, starttime, [0.1,0.05].choose, 127,
		track: 1 )
});

// add some random  CCs
((0,(1/8)..5)).do({ |starttime|
	m.addMIDITypeEvent(type: 'cc', args: [7, 128.rand], absTime: starttime,
		track: 1 )
});

m.adjustEndOfTrack; // may not be really needed, but nice if you want to do m.plot

m.write
)