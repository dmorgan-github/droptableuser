
MIDIClient.init;
MIDIIn.connectAll;
MIDIIn.disconnectAll;
MIDIClient.sources;

(
/*
48 to 72
*/
MIDIdef.noteOn(\noteOn, {arg ...args;
	var note = args[1];
	Fdef(\noteOn).value(note);
});
MIDIdef.noteOff(\noteOff, {arg ...args;
	var note = args[1];
	Fdef(\noteOff).value(note);
});
)

MIDIIn.doNoteOnAction(1, 1, 64, 64); // spoof a note on
MIDIIn.doNoteOffAction(1, 1, 64, 64); // spoof a note on

MIDIIn.doControlAction(1, 1, 1, 64); // spoof a cc
MIDIIn.doControlAction(1, 1, 9, 64);
MIDIIn.doControlAction(1, 10, 1, 64);


