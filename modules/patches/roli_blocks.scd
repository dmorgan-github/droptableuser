
MIDIClient.init;
MIDIClient.sources;
MIDIIn.connectAll;

a = MIDIFunc.cc({arg ...args; args.postln}, 1); // match cc 1
a.free; // cleanup

b = MIDIFunc.cc({arg ...args; args.postln}, 1, 1); // match cc1, chan 1
b.free; // cleanup

c = MIDIFunc.cc({arg ...args; args.postln}, (1..10)); // match cc 1-10
c.free; // cleanup

(
n = MIDIFunc.noteOn({arg ...args;

}); // match any noteOn
)
n.free; // cleanup

(
MIDIdef.noteOn(\test4, {arg ...args;
	var note = args[1] + 12;
	args.postln;
	~p[\sine].set(\freq, note.midicps)
});
)

MIDIIn.doNoteOnAction(1, 1, 64, 64); // spoof a note on
MIDIIn.doControlAction(1, 1, 1, 64); // spoof a cc
MIDIIn.doControlAction(1, 1, 9, 64);
MIDIIn.doControlAction(1, 10, 1, 64);