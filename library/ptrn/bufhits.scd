(
func: {
    Plazy({
        var count = Pseries(0, 1).asStream;
        Plazy({|env|

            var bufs = env['bufs'];
            var vals = env['hits'];
            var current = count.next;
            var hits = vals.collect({|val, i|

                var hit = val.asArray.wrapAt(current);
                var buf = bufs.wrapAt(i);

                if (hit.isNumber and: {hit.coin} ) {
                    hit = 1;
                } {
                    hit = \;
                };
                (buf:buf, hit:hit).repeat(1)
            });

            Ppar(hits)
        }).repeat
    })
};
)