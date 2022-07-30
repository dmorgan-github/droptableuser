(
func: {

    var seq = EventPatternProxy();
    seq.source = Pspawner({|sp|

        var data;
        var instrs, ptrns, tatum;
        var cnt = 0, cell, stream;

        inf.do({

            var vals;
            data = sp.event;
            instrs = data['instrs'] ?? [];
            ptrns = data['ptrns'] ?? [];
            tatum = data['tatum'] ?? 1;

            vals = ptrns.asArray.collect({|row, i|
                row.asArray.wrapAt(cnt)
            });

            instrs.asArray.do({|instr, i|
                stream = instrs.asArray.wrapAt(i);
                sp.par(Pbind(\dur, Pn(tatum, 1)) <> stream.next( (vals:vals, cnt:cnt) ) );
            });

            cnt = cnt + 1;
            sp.wait(tatum);
        });

    });

    seq;
},
doc: "
~seq = Module('device/stepval').()
~seq.play
~seq.stop
(
~seq.set(
    // don't forget asStream
    'instrs', [
        ~fd.pfilter(\degree, Pkey(\val)).asStream,
        ~bass.pfilter(\degree, Pkey(\val)).asStream
    ],
    'ptrns', [
        [7, \, \],
        [5, \, 1, 1]
    ],
    'tatum', 0.25
)
)
"
)
