(
func: {|node|
    var curves, levels, times;
    var view = View().layout_(VLayout().spacing_(0).margins_(0));
    var atkspec, decspec, relspec, atkcurvespec, deccurvespec, relcurvespec;
    var listener, prevy;
    var curvesupdater, timesupdater, levelsupdater;
    var atkmapped, decmapped, relmapped;

    var envview = EnvelopeView()
    .keepHorizontalOrder_(true)
    .elasticSelection_(true)
    .editable_(true)
    .strokeColor_(node.color)
    .gridColor_(Color.gray)
    .background_(Color.clear)
    .thumbSize_(20)
    .grid_(Point(0.25, 0.25))
    .gridOn_(true)
    .step_(0.0001);

    /*
    listener = {|obj, what, vals|
        {
            if (what == \set) {
                var ischanged = false;
                vals.pairsDo({|k, v|
                    if (k == \rel) {
                        if (v != times[times.size-1]) {
                            times[times.size-1] = v;
                            ischanged = true;
                        }
                    };
                    if (k == \atk) {
                        if (v != times[1]) {
                            times[1] = v;
                            ischanged = true;
                        }
                    };
                    if (k == \dec) {
                        if (v != times[2]) {
                            times[2] = v;
                            ischanged = true;
                        }
                    };
                    if (k == \suslevel) {
                        if (v != levels[2]) {
                            levels[2] = v;
                            ischanged = true;
                        }
                    };
                    if (k == \relcurve) {
                        if (v != curves[curves.size-1]) {
                            curves[curves.size-1] = v;
                            ischanged = true;
                        }
                    };
                    if (k == \deccurve) {
                        if (v != curves[1]) {
                            curves[1] = v;
                            ischanged = true;
                        }
                    };
                    if (k == \atkcurve) {
                        if (v != curves[0]) {
                            curves[0] = v;
                            ischanged = true;
                        }
                    };

                });
                //if (ischanged) {
                //    envview.curves = curves;
                //    envview.value = [ times, levels ];
                //}
            }
        }.defer
    };
    */

    curves = [node.get('atkcurve'), node.get('deccurve'), node.get('relcurve')];
    levels = [0, 1, node.get('suslevel'), 0];

    atkmapped = node.get('atk').linlin(0, 8, 0, 0.25);
    decmapped = node.get('dec').linlin(0, 1, atkmapped, 0.5);
    relmapped = node.get('rel').linlin(0, 8, decmapped, 1);
    times = [
        0,
        atkmapped,
        decmapped,
        relmapped
    ];

    atkspec = node.getSpec('atk');
    decspec = node.getSpec('dec');
    relspec = node.getSpec('rel');
    atkcurvespec = node.getSpec('atkcurve');
    deccurvespec = node.getSpec('deccurve');
    relcurvespec = node.getSpec('relcurve');

    curvesupdater = {|obj, which|
        if (which == 0) {
            node.set('atkcurve', obj[which])
        } {
            if (which == (curves.size-1)) {
                node.set('relcurve', obj[which])
            } {
                node.set('deccurve', obj[which])
            }
        }
    };

    timesupdater = {|obj, which|
        if (which > 0) {
            if (which == 1) {
                var val = times[which].linlin(0, 0.25, 0, 8);
                node.set('atk', val)
            } {
                if (which == (times.size-1)) {
                    var val;
                    decmapped = times[2];
                    val = times[which].linlin(decmapped, 1, 0, 8);
                    node.set('rel', val)
                } {
                    var val;
                    var atkmapped = times[1];
                    val = times[which].linlin(atkmapped, 0.5, 0, 1);
                    node.set('dec', val)
                }
            }
        }
    };

    levelsupdater = {|obj, which|
        if (which == 2) {
            node.set('suslevel', obj[which])
        }
    };

    curves.addDependant(curvesupdater);
    times.addDependant(timesupdater);
    levels.addDependant(levelsupdater);

    envview
    .value_([ times, levels ])
    .curves_(curves)
    .action_({|ctrl|
        var index = ctrl.index;
        if (index == 1) {
            ctrl.y = 1.0;
            if (ctrl.x > 0.25) {
                ctrl.x = 0.25
            }
        };
        if (index == 2) {
            if (ctrl.x > 0.5) {
                ctrl.x = 0.5
            };
        };
        if (index == (times.size-1)) {
            ctrl.y = 0.0
        };
        times[index] = ctrl.value[0][index];
        levels[index] = ctrl.value[1][index];
        times.changed(ctrl.index);
        levels.changed(ctrl.index);
    })
    .mouseDownAction_({|ctrl, x, y, modifiers|
        if (modifiers == 262144) {
            ctrl.editable = false;
        };
        prevy = y;
    })
    .mouseUpAction_({|ctrl|
        ctrl.editable = true
    })
    .mouseMoveAction_({|ctrl, x, y, modifiers|
        var index = ctrl.index;
        if (modifiers == 262144 and: {index > 0}) {
            if (y < prevy) {
                var val = clip(curves[index-1] + 0.1, -8, 8);
                curves[index-1] = val;
                curves.changed(index-1);
                ctrl.curves = curves;
            } {
                if (y > prevy) {
                    var val = clip(curves[index-1] - 0.1, -8, 8);
                    curves[index-1] = val;
                    curves.changed(index-1);
                    ctrl.curves = curves;
                }
            };
            prevy = y;
        }
    })
    ;

    envview.setEditable(0, false);
    view.layout.add(envview);
    //node.addDependant(listener);

    view.onClose_({
        node.removeDependant(listener);
    })
}
)
