(
func: {|node|
    var curves, levels, times;
    var view = View().layout_(VLayout().spacing_(0).margins_(0));
    var atkspec, relspec, atkcurvespec, relcurvespec;
    var listener, prevy;
    var curvesupdater, timesupdater, levelsupdater;
   
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
                if (ischanged) {
                    envview.curves = curves;
                    envview.value = [ times, levels ];
                }
            }
        }.defer
    };

    curves = [0, 0];
    levels = [0, 1, 0];
    times = [0, 0, 0];

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
    };

    curves[0] = node.get('atkcurve');
    curves[curves.size-1] = node.get('relcurve');

    times[1] = node.get('atk');
    times[times.size-1] = node.get('rel');

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
                node.set('atk', times[which])
            } {
                if (which == (times.size-1)) {
                    node.set('rel', times[which])
                } {
                    node.set('dec', times[which])
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
            ctrl.y = 1.0
        } {
            if (index == (times.size-1)) {
                ctrl.y = 0.0
            }
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
    node.addDependant(listener);

    view.onClose_({
        node.removeDependant(listener);
    })
}
)
