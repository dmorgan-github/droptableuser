
MIDIClient.init;
MIDIIn.connectAll;
MIDIIn.disconnectAll;
MIDIClient.sources;
MIDIdef.freeAll;

(
/*
48 to 72
*/
MIDIdef.noteOn(\noteOn, {arg ...args;
	var note = args[1];
	var vel = args[0];
	var chan = args[2];
	var key = ('noteOn' ++ chan).asSymbol;
	Fdef(key).value(note, vel);
});
MIDIdef.noteOff(\noteOff, {arg ...args;
	var note = args[1];
	var vel = args[0];
	var chan = args[2];
	var key = ('noteOff' ++ chan).asSymbol;
	Fdef(key).value(note, vel);
});
)


/////////////////////////////////////////
// triggers
(
MIDIdef.noteOn(\noteOn, {arg ...args;
	var note = args[1];
	var key = ('noteOn/' ++ note).asSymbol;
	[key].postln;
	Fdef(key).value();
});
MIDIdef.noteOff(\noteOff, {arg ...args;
	var note = args[1];
	var key = ('noteOff/' ++ note).asSymbol;
	[key].postln;
	Fdef(key).value();
});
)

MIDIIn.doNoteOnAction(1, 1, 64, 64); // spoof a note on
MIDIIn.doNoteOffAction(1, 1, 64, 64); // spoof a note on
MIDIIn.doControlAction(1, 1, 1, 64); // spoof a cc
MIDIIn.doControlAction(1, 1, 9, 64);
MIDIIn.doControlAction(1, 10, 1, 64);


