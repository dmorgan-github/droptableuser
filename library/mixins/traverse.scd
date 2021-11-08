/*
(
~data = [
    [0, 1, 2, 3, 4],
    [5, 6, 7, 8, 9],
    [10, 11, 12, 13, 14],
    [15, 16, 17, 18, 19],
    [20, 21, 22, 23, 24]
]
)

Pdef(\test, Pdef(\traverse) <> Pbind(\data, ~data, \by, \col, \skip, 2))
Pdef(\test).play
Pdef(\test).stop
*/

(
Pdef(\traverse, Pbind(
    'val', Prout({|evt|
        var data = evt[\data];
        var skip = evt[\skip] ?? {1};
        var to = evt[\to] ?? {data.size};
        var from = evt[\from] ?? {0};
        var by = evt[\by] ?? {\row};
        if (by == \col) {
            data = data.flop;
        };
        inf.do({
            forBy(from, to, skip, {|i|
                var row = i;
                var num = data[row].size;
                num.do({|j|
                    var val = data[row][j];
                    val.yield;
                })
            });
        })
    })
));

/*
Pdef('\traverseXY').set(\data, ~data, \x, [0, 1, 1, 2, 3, 3, 3], \y, [0, 1, 3].mirror)
*/
Pdef(\traverseXY, Pbind(

    'y', Pfunc({|evt|
        var y = evt[\y];
        if (y.isNil) {
            y = [0]
        };
        y;
    }),

    'x', Pfunc({|evt|
        var x = evt[\x];
        if (x.isNil) {
            x = [0]
        };
        x
    }),

    'xval', Pbinop(\wrapAt, Pkey(\x), Pseries(0, 1, inf)),

    'yval', Pbinop(\wrapAt, Pkey(\y), Pseries(0, 1, inf)),

    'val', Pfunc({|evt|
        var y = evt['yval'];
        var x = evt['xval'];
        var data = evt['data'];
        var val = data[y][x];
        val
    }),
));
)
