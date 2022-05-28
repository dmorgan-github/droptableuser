(
func: {|node|
    var curves, levels, times;
    var view = View().layout_(VLayout().spacing_(0).margins_(0));
    var knobview = View().layout_(VLayout().spacing_(0).margins_(0));
    var xyknobs = List.new, curveknobs = List.new;
    var atkspec, relspec, atkcurvespec, relcurvespec;

    var envview = EnvelopeView()
    .keepHorizontalOrder_(true)
    .editable_(false)
    .strokeColor_(node.color)
    .step_(0.0001);

    curves = [0, 0];
    levels = [0, 1, 0];
    times = [0, 0, 0];

    xyknobs.addAll([Knob(), Knob()]);
    curveknobs.addAll([Knob(), Knob()]);

    atkspec = node.getSpec('atk');
    relspec = node.getSpec('rel');
    atkcurvespec = node.getSpec('atkcurve');
    relcurvespec = node.getSpec('relcurve');

    if (node.getSpec['dec'].notNil) {

        var decspec = node.getSpec('dec');
        var deccurvespec = node.getSpec('deccurve');

        curves = [0, node.get('deccurve'), 0];
        levels = [0, 1, node.get('suslevel'), 0];
        times = [0, 0, node.get('dec'), 0];

        xyknobs.addAll([Knob(), Knob()]);
        curveknobs.add(Knob());

        xyknobs[1]
        .value_(decspec.unmap(times[2]))
        .action_({|ctrl|
            var val = ctrl.value;
            var mapped = decspec.map(val);
            times[2] = mapped;
            envview.value = [times, levels];
            ctrl.toolTip = mapped;
            node.set('dec', mapped);
        });

        xyknobs[2]
        .value_(levels[2])
        .action_({|ctrl|
            var val = ctrl.value;
            levels[2] = val;
            envview.value = [times, levels];
            ctrl.toolTip = val;
            node.set('suslevel', val);
        });

        curveknobs[1]
        .value_(deccurvespec.unmap(curves[1]))
        .action_({|ctrl|
            var val = ctrl.value;
            var mapped = deccurvespec.map(val);
            curves[1] = mapped;
            envview.curves = curves;
            ctrl.toolTip = curves[1];
            node.set('deccurve', mapped);
        })
    };

    curves[0] = node.get('atkcurve');
    curves[curves.size-1] = node.get('relcurve');

    times[1] = node.get('atk');
    times[times.size-1] = node.get('rel');

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
    });

    // rel
    xyknobs[xyknobs.size-1]
    .value_(relspec.unmap(times[times.size-1]))
    .action_({|ctrl|
        var val = ctrl.value;
        var mapped = relspec.map(val);
        times[times.size-1] = mapped;
        envview.value = [times, levels];
        ctrl.toolTip = mapped;
        node.set('rel', mapped);
    });

    curveknobs[0]
    .value_(atkcurvespec.unmap(curves[0]))
    .action_({|ctrl|
        var val = ctrl.value;
        var mapped = atkcurvespec.map(val);
        curves[0] = mapped;
        envview.curves = curves;
        ctrl.toolTip = mapped;
        node.set('atkcurve', mapped);
    });

    curveknobs[curveknobs.size-1]
    .value_(relcurvespec.unmap(curves[curves.size-1]))
    .action_({|ctrl|
        var val = ctrl.value;
        var mapped = relcurvespec.map(val);
        curves[curves.size-1] = mapped;
        envview.curves = curves;
        ctrl.toolTip = mapped;
        node.set('relcurve', mapped);
    });

    envview.value = [ times, levels ];
    envview.curves = curves;

    knobview.layout.add(HLayout(
        *xyknobs.collect({|knob|
            knob.maxSize_(Size(25, 25)).step_(0.005)
        });
    ));

    knobview.layout.add(HLayout(
        *curveknobs.collect({|knob|
            knob.maxSize_(Size(25, 25)).step_(0.005)
        });
    ));

    view.layout.add(envview);
    view.layout.add(knobview);
    view
    //.minSize_(Size(400, 200))
}
)