(
Pdef(\sequencer, Pbind(

    \count, Pseries(0),

    \degree, Pbinop(
        \wrapAt,
        Pfunc({|evt|
            var val = evt[\degree];
            if (val.isNil) {
                val = [0]
            };
            val.asArray;
        }),
        Pkey(\count)
    ),
    \octave, Pbinop(
        \wrapAt,
        Pfunc({|evt|
            var val = evt[\octave];
            if (val.isNil) {
                val = [5]
            };
            val.asArray;
        }),
        Pkey(\count)
    ),
    \mtranspose, Pbinop(
        \wrapAt,
        Pfunc({|evt|
            var val = evt[\mtranspose];
            if (val.isNil) {
                val = [0]
            };
            val.asArray;
        }),
        Pkey(\count)
    ),
    \prob, Pbinop(
        \wrapAt,
        Pfunc({|evt|
            var val = evt[\prob];
            if (val.isNil) {
                val = [1]
            };
            val.asArray;
        }),
        Pkey(\count)
    ),
    \hit, Pfunc({|evt|
        if (evt[\prob].coin) {
            1
        }{
            Rest(1)
        }
    }),
    \durval, Pbinop(
        \wrapAt,
        Pfunc({|evt|
            var val = evt[\durs];
            if (val.isNil) {
                val = [1]
            };
            val.asArray;
        }),
        Pkey(\count)
    ),
    \dur, Pfunc({|evt|
        var dur = evt[\durval];
        if (dur.isNumber) {
            dur
        }{
            1
        }
    })
));

Pdef(\variseq, {|evt|

    var vals = [\count, Pseries(0)];
    var keys = ~keys ?? { [\val] };

    vals = vals ++ keys.collect({|key|
        [key, Pbinop(
            \wrapAt,
            Pfunc({|evt|
                var val = evt[key];
                if (val.isNil) {
                    val = [1]
                };
                val.asArray;
            }),
            Pkey(\count)
        )
        ];
    }).flatten;

    vals = vals ++ [
        \prob, Pbinop(
            \wrapAt,
            Pfunc({|evt|
                var val = evt[\prob];
                if (val.isNil) {
                    val = [1]
                };
                val.asArray;
            }),
            Pkey(\count)
        ),
        \hit, Pfunc({|evt|
            if (evt[\prob].coin) {
                1
            }{
                Rest(1)
            }
        }),
        \durval, Pbinop(
            \wrapAt,
            Pfunc({|evt|
                var val = evt[\durs];
                if (val.isNil) {
                    val = [1]
                };
                val.asArray;
            }),
            Pkey(\count)
        ),
        \dur, Pfunc({|evt|
            var dur = evt[\durval];
            if (dur.isNumber) {
                dur
            }{
                evt[\dur].postln
            };
        })
    ];

    Pbind(*vals)
});

)
