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
~seq = Module('device/stepval2').()
~seq.play
~seq.stop
(
~seq.set(

    'ptrns', [
        A.randseq(16, 0.5, -3, 9),
        A.randseq(24, 0.3, 0, 9),
    ],
    // don't forget asStream
    'instrs', [

        ~res.degree_(Pfunc({|evt|
            var cnt = evt['cnt'];
            var vals = evt['vals'];
            var val1 = vals[0];
            var val2 = vals[1];
            //[val1, val2].choose
            val1
        }))
        .octave_(4),

        ~res.degree_(Pfunc({|evt|
            var cnt = evt['cnt'];
            var vals = evt['vals'];
            var val1 = vals[0];
            var val2 = vals[1];
            //[val1, val2].choose
            val2
        }))
        .octave_(5)

    ].collect(_.asStream),

    'tatum', 0.25
)
)
"
)
