(
(
Pdef(\seq, {
    Pbind(
        \step, Pkey(\step).ifnil(1),
        \count, Pseries(0, Pkey('step')),
        \val, Pfunc({|evt|
            var count = evt['count'];
            var vals = evt['data'].value;
            var val = vals.wrapAt(count);
            val
        })
    )
})
)
)