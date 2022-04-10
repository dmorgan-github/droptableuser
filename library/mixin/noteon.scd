(
/*
~m = MIDIOut.newByName("IAC Driver", "Bus 1");
~m.connect
~m.noteOn(0, 60, 60);
~m.noteOff(0, 60, 60);
*/
Pdef(\noteon, {|midiout, chan=0|
    Pbind(
        \type, \midi,
        \midicmd, \noteOn,
        \midiout, midiout,
        \chan, chan.postln
    )
})
)

