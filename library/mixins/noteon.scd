(
Pdef(\noteon, {|midiout, chan=0|
    Pbind(
        \type, \midi,
        \midicmd, \noteOn,
        \midiout, midiout,
        \chan, chan
    )
})
)

