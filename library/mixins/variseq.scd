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
        \hits, Pbinop(
            \wrapAt,
            Pfunc({|evt|
                var val = evt[\hits].value;
                if (val.isNil) {
                    val = [1];
                } {
                    if (val.isString) {
                        val = CollStream(val).all.collect({|char|
                            if (char.isDecDigit) { char.digit/9 }{0}
                        })
                    }
                };
                val.asArray;
            }),
            Pkey(\count)
        ).collect({|val|
            if (val.coin) {1} {Rest(1)}
        })
    ];

    Pbind(*vals)
});

)
