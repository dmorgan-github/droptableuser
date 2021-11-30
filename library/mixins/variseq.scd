(
Pdef(\variseq, {

    var algo = if (~algo.notNil) {
        ~algo
    }{
        Pseries(0)
    };

    var vals = [\count, algo, \beat, Ptime()];
    var keys = currentEnvironment['variseq/keys'] ?? { ['degree'] };

    vals = vals ++ keys.collect({|key|
        [key, Pbinop(
            \wrapAt,
            Pfunc({|evt|
                var cycle = evt[\cycle] ?? 0;
                var val = evt[key].value(cycle);
                if (val.isNil) {
                    val = [1]
                };
                val.asArray;
            }),
            Pkey(\count)
        ).collect({|val, evt|
            var cnt = evt[\count];
            val.value(cnt, evt)
        })
        ];
    }).flatten;

    vals = vals ++ [
        \prob, Pbinop(
            \wrapAt,
            Pfunc({|evt|
                var val = evt[\prob].value;
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
                var val = evt[\durs].value;
                if (val.isNil) {
                    val = [1]
                };
                val.asArray;
            }),
            Pkey(\count)
        ),
        \dur, Pfunc({|evt|
            var dur = evt[\durval].value;
            if (dur.isNumber) {
                dur
            }{
                evt[\dur]
            };
        })
    ];

    Pbind(*vals)
});

)
