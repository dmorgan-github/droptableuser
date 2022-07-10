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

            ptrns.do({|row, i|
                cell = row.wrapAt(cnt);
                if (cell.isRest.not and: { cell.isNil.not }) {
                    var prob = 1;
                    if (prob.coin) {
                        stream = instrs.wrapAt(i);
                        sp.par( Pbind(\dur, tatum).finDur(tatum) <> stream.next( (val:cell) ) <> Pbind(\val, cell) );
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
~seq2.set(
    // don't forget asStream
    'instrs', [~fd.asStream, ~bass.asStream],
    'ptrns', [
        [7, \, \],
        [5, \, 1, 1]
    ],
    'tatum', 0.25
)
)
"
)