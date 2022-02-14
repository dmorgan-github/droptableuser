var getdata = {|scale='major', interval=7, root=36|

    var degrees, data, size;
    root = root ?? {'c1'.namemidi};
    interval = interval ?? {7};
    scale = scale ?? {'major'};

    degrees = Scale.at(scale.asSymbol).degrees;// ++ [12];
    size = degrees.size;
    data = degrees.collect({|degree|
        var val = root + degree + (interval * (0..(size-1)));
        val.nearestInScale(degrees);
    });
    data;
};

(
func: {

    var on = ~on ?? { {|note| note.debug(\on) } };
    var off = ~off ?? { {|note| note.debug(\off) } };
    var data = getdata.(~scale, ~interval, ~root);
    var gridrows = 8;
    var gridcols = 16;
    var numbuttons = gridrows * gridcols;
    var buttons = Array.fill(numbuttons, {0});

    OSCdef(\modes, {|msg|

        var x = msg[1];
        var y = msg[2];
        var val = msg[3];

        if ((gridrows-1-y) < data.size and: {x < data[0].size}) {
            if (val == 1) {
                var num = numbuttons - ((gridcols-x) + (gridcols * y));
                var state;
                var note;
                buttons[num] = (1-buttons[num]);
                ~monome.levset(x, y, buttons[num] * 6);//~buttons[num].debug(\here);
                note = data.wrapAt(7-y).wrapAt(x);

                if (buttons[num] > 0) {
                    on.(note);
                }{
                    off.(note)
                };
            };
        }

    }, '/monome/grid/key')
    .permanent_(true);
}
)