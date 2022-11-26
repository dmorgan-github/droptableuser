(
func: {|node|
    var curves, levels, times;
    var view = View().layout_(VLayout().spacing_(0).margins_(0));
   // var knobview = View().layout_(VLayout().spacing_(0).margins_(0));
    //var xyknobs = List.new, curveknobs = List.new;
    var atkspec, relspec, atkcurvespec, relcurvespec;
    var listener;

    var envview = EnvelopeView()
    .keepHorizontalOrder_(true)
    .editable_(false)
    .strokeColor_(node.color)
    .gridColor_(Color.gray)
    .background_(Color.clear)
    .grid_(Point(0.25, 0.25))
    .gridOn_(true)
    .thumbSize_(20)
    .step_(0.0001);

    curves = [0, 0];
    levels = [0, 1, 0];
    times = [0, 0, 0];

    listener = {|obj, what, vals|
        {
            if (what == \set) {
                vals.pairsDo({|k, v|
                    if (k == \frel) {
                        times[times.size-1] = v;
                    };
                    if (k == \fatk) {
                        times[1] = v;
                    };
                    if (k == \fdec) {
                        times[2] = v;
                    };
                    if (k == \fsuslevel) {
                        levels[2] = v
                    };
                    if (k == \frelcurve) {
                        curves[curves.size-1] = v;
                    };
                    if (k == \fdeccurve) {
                        curves[1] = v;
                    };
                    if (k == \fatkcurve) {
                        curves[0] = v;
                    };
                    envview.curves = curves;
                    envview.value = [ times, levels ];
                })
            }
        }.defer
    };

    //xyknobs.addAll([Knob().background_(Color.clear), Knob().background_(Color.clear)]);
    //curveknobs.addAll([Knob().background_(Color.clear), Knob().background_(Color.clear)]);

    atkspec = node.getSpec('fatk');
    relspec = node.getSpec('frel');
    atkcurvespec = node.getSpec('fatkcurve');
    relcurvespec = node.getSpec('frelcurve');

    if (node.getSpec['fdec'].notNil) {

        var decspec = node.getSpec('fdec');
        var deccurvespec = node.getSpec('fdeccurve');

        curves = [0, node.get('fdeccurve'), 0];
        levels = [0, 1, node.get('fsuslevel'), 0];
        times = [0, 0, node.get('fdec'), 0];

        //xyknobs.addAll([Knob().background_(Color.clear), Knob().background_(Color.clear)]);
        //curveknobs.add(Knob().background_(Color.clear));

        /*
        xyknobs[1]
        .value_(decspec.unmap(times[2]))
        .action_({|ctrl|
            var val = ctrl.value;
            var mapped = decspec.map(val);
            times[2] = mapped;
            envview.value = [times, levels];
            ctrl.toolTip = mapped;
            node.set('fdec', mapped);
        })
        .toolTip_(times[2])
        ;
        */

        /*
        xyknobs[2]
        .value_(levels[2])
        .action_({|ctrl|
            var val = ctrl.value;
            levels[2] = val;
            envview.value = [times, levels];
            ctrl.toolTip = val;
            node.set('fsuslevel', val);
        })
        .toolTip_(levels[2])
        ;
        */

        /*
        curveknobs[1]
        .value_(deccurvespec.unmap(curves[1]))
        .action_({|ctrl|
            var val = ctrl.value;
            var mapped = deccurvespec.map(val);
            curves[1] = mapped;
            envview.curves = curves;
            ctrl.toolTip = curves[1];
            node.set('fdeccurve', mapped);
        })
        .toolTip_(curves[1])
        */
    };

    curves[0] = node.get('fatkcurve');
    curves[curves.size-1] = node.get('frelcurve');

    times[1] = node.get('fatk');
    times[times.size-1] = node.get('frel');

    /*
    // atk
    xyknobs[0]
    .value_(atkspec.unmap(times[1]))
    .action_({|ctrl|
        var val = ctrl.value;
        var mapped = atkspec.map(val);
        times[1] = mapped;
        envview.value = [times, levels];
        ctrl.toolTip = mapped;
        node.set('atk', mapped);
    })
    .toolTip_(times[1])
    ;
    */

    /*
    // rel
    xyknobs[xyknobs.size-1]
    .value_(relspec.unmap(times[times.size-1]))
    .action_({|ctrl|
        var val = ctrl.value;
        var mapped = relspec.map(val);
        times[times.size-1] = mapped;
        envview.value = [times, levels];
        ctrl.toolTip = mapped;
        node.set('frel', mapped);
    })
    .toolTip_(times[times.size-1])
    ;
    */

    /*
    curveknobs[0]
    .value_(atkcurvespec.unmap(curves[0]))
    .action_({|ctrl|
        var val = ctrl.value;
        var mapped = atkcurvespec.map(val);
        curves[0] = mapped;
        envview.curves = curves;
        ctrl.toolTip = mapped;
        node.set('fatkcurve', mapped);
    })
    .toolTip_(curves[0])
    ;
    */

    /*
    curveknobs[curveknobs.size-1]
    .value_(relcurvespec.unmap(curves[curves.size-1]))
    .action_({|ctrl|
        var val = ctrl.value;
        var mapped = relcurvespec.map(val);
        curves[curves.size-1] = mapped;
        envview.curves = curves;
        ctrl.toolTip = mapped;
        node.set('frelcurve', mapped);
    })
    .toolTip_(curves[curves.size-1])
    ;
    */

    envview.value = [ times, levels ];
    envview.curves = curves;

    /*
    knobview.layout.add(HLayout(
        *(xyknobs.collect({|knob|
            knob.maxSize_(Size(25, 25)).step_(0.001)
        }) ++ [nil])
    ).margins_(3).spacing_(10));
    */

    /*
    knobview.layout.add(HLayout(
        *(curveknobs.collect({|knob|
            knob.maxSize_(Size(25, 25)).step_(0.001)
        }) ++ [nil])
    ).margins_(3).spacing_(10));
    */

    view.layout.add(envview);
    //view.layout.add(knobview);

    node.addDependant(listener);

    view.onClose_({
        node.removeDependant(listener);
    })

}
)
