(
func: {

    var seq = EventPatternProxy();
    seq.source = Pspawner({|sp|

        var data;
        var instrs, ptrns, tatum;
        var cnt = 0, cell, stream;

        inf.do({

            data = sp.event;
            instrs = data['instrs'] ?? [];
            ptrns = data['ptrns'] ?? [];
            tatum = data['tatum'] ?? 1;

            ptrns.asArray.do({|row, i|
                cell = row.asArray.wrapAt(cnt);
                if (cell.isRest.not and: { cell.isNil.not }) {
                    var prob = 1;
                    if (prob.coin) {
                        stream = instrs.asArray.wrapAt(i);
                        sp.par( Pbind(\dur, tatum).finDur(tatum) <> stream.next( (val:cell) ) );
                    }
                };
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
