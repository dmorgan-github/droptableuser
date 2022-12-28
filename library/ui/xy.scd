(
func: {|node|
    var view;
    var slider;
    var props;
    var layout;
    var axis;
    var range;
    var prop;
    var updatesettings;
    var xypos = [0, 0];
    var tuples = {
        var cached = Halo.at(node.key, \xytuples);
        if (cached.isNil) {
            cached = [
                [nil, \x, 0, 1],
                [nil, \x, 0, 1],
                [nil, \x, 0, 1],
                [nil, \x, 0, 1],
                [nil, \x, 0, 1]
            ];
        };
        Halo.put(node.key, \xytuples, cached);
        cached
    }.();

    xypos = {
        var cached = Halo.at(node.key, \xypos);
        if (cached.isNil) {
            cached = [0, 0];
        };
        Halo.put(node.key, \xypos, cached);
        cached;
    }.();

    updatesettings = {|a, b, c, d|
        tuples[b][c] = d;
    };

    tuples.addDependant(updatesettings);

    axis = {|num|

        PopUpMenu()
        .action_({|ctrl|
            var val = ctrl.item.asSymbol;
            tuples.changed(num, 1, val)
        })
        .items_(["x", "y"])
        .value_([\x, \y].indexOf(tuples[num][1] ))
        .background_(Color.clear)
    };

    range = {|num|
        RangeSlider()
        .orientation_(\horizontal)
        .action_({|ctrl|
            tuples[num][2] = ctrl.lo;
            tuples[num][3] = ctrl.hi;
        })
       .lo_(tuples[num][2])
       .hi_(tuples[num][3])
       .background_(Color.clear)
       .knobColor_(Color.white.alpha_(0.5))
    };

    prop = {|num|
        var val = tuples[num][0] ?? "";
        TextField()
        .action_({|ctrl|
            var val = ctrl.value;
            if (val != "") {
                tuples[num][0] = val.asSymbol;
            }
        })
        .background_(Color.clear)
        .value_(val)
    };

    view = View();
    slider = Slider2D().action_({|ctrl|

        var x = tuples.select({|a| (a[0].notNil) and: {a[1] == \x} });
        var y = tuples.select({|a| (a[0].notNil) and: {a[1] == \y} });
        var valx = ctrl.x;
        var valy = ctrl.y;
        var vals;

        var getvals = {|array, val|
            array.collect({|a|
                var prop = a[0];
                var min = a[2];
                var max = a[3];

                var spec = node.getSpec[prop] ?? [0, 1].asSpec;
                var specmin = spec.minval;
                var specmax = spec.maxval;
                var specstep = spec.step;

                min = min.linlin(0, 1, specmin, specmax);
                max = max.linlin(0, 1, specmin, specmax);
                val = val.linlin(0, 1, min, max).round(specstep);
                [prop, val]
            }).flatten;
        };

        vals = getvals.(x, valx) ++ getvals.(y, valy);
        if (vals.size > 0) {
            node.set(*vals);
        };
        xypos = [ctrl.x, ctrl.y];

    })
    .background_(Color.clear)
    .x_(xypos[0])
    .y_(xypos[1]);

    props = VLayout(
        HLayout(prop.(0), axis.(0), range.(0)),
        HLayout(prop.(1), axis.(1), range.(1)),
        HLayout(prop.(2), axis.(2), range.(2)),
        HLayout(prop.(3), axis.(3), range.(3)),
        HLayout(prop.(4), axis.(4), range.(4))
    ).margins_(0).spacing_(0);

    layout = VLayout(
        slider.minSize_(Size(250, 100)),
        props
    ).margins_(0).spacing_(0);

    view.layout = layout;
    view.background = Color.clear;
    view.onClose = {
        "xy".debug("close");
        Halo.put(node.key, \xytuples, tuples);
        Halo.put(node.key, \xypos, xypos)
    };
    view
}
)
