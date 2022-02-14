(
Pdef(\ploopr,
    Pspawner({|sp|
        inf.do({|i|
            var note, pattern;
            var new = ~notes.pop;
            var size = ~loopbuf.indices.size;
            var div = ~div ?? {0.125};
            while ({new.notNil}) {
                var num = i.mod(size);
                ~loopbuf[num].add(new);
                new = ~notes.pop;
            };
            note = ~loopbuf.wrapAt(i);
            if (note.size > 0) {
                var notes = note.asArray;
                pattern = Pbind(\midinote, notes)
            }{
                pattern = Pn(Event.silent);
            };
            sp.seq(pattern.finDur(div))
        })
    })
)
)

/*
~notes1 = List.new
~buffer1 = Order.new;
~num1 = 8;
~num1.do({|i| ~buffer1[i] = List.new;});

(
var num = ~num;
Ndef(\m)[1] = Pbind(\instrument, \modal)
<> Pbind(\foo, Pfunc({ if (0.8.coin) {1}{ Rest(1) } }))
<> Penvir((notes:~notes1, loopbuf:~buffer1, div:(num/4).reciprocal), Pdef(\ploopr), false)
)
*/
