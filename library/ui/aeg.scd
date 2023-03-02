(
func: {|node, prefix|

    var model;
    var view = View().layout_(VLayout().spacing_(0).margins_(0));
    var envview;
    var curves, levels, times;
    var getval, getspec, getcurves, getlevels, gettimes, setval;
    var curvesupdater, timesupdater, levelsupdater;
    var prevy;

    model = (
        atk: 0.01,
        dec: 0.2,
        rel: 1,
        suslevel: 1,
        atkcurve: -4,
        deccurve: -4,
        relcurve: -4,
        hasdecay: false,

        atk_: {|self, val| 
            self['atk'] = val; 
            self.changed(\atk, val) 
        },
        dec_: {|self, val| 
            self['dec'] = val;
            if (val.notNil) {
                self['hasdecay'] = true;
                self.changed(\dec, val)
            }
        },
        rel_: {|self, val| 
            self['rel'] = val; 
            self.changed(\rel, val) 
        },
        suslevel_: {|self, val| 
            self['suslevel'] = val; 
            self.changed(\suslevel, val)
        },
        atkcurve_: {|self, val|
            self['atkcurve'] = val; 
            self.changed(\atkcurve, val)
        },
        deccurve_: {|self, val| 
            self['deccurve'] = val; 
            self.changed(\deccurve, val)
        },
        relcurve_: {|self, val| 
            self['relcurve'] = val; 
            self.changed(\relcurve, val)
        }
    );

    setval = {|key, val|
        key = if (prefix.notNil) { "%%".format(prefix, key).asSymbol } { key };
        node.set(key, val);
    };

    getval = {|key|
        key = if (prefix.notNil) { "%%".format(prefix, key).asSymbol } { key };  
        node.get(key)
    };

    getspec = {|key|
        key = if (prefix.notNil) { "%%".format(prefix, key).asSymbol } { key };
        node.getSpec[key];
    };

    getcurves = {
        if (model.hasdecay) {
            [model.atkcurve, model.deccurve, model.relcurve]
        }{
            [model.atkcurve, model.relcurve]
        }
    };

    getlevels = {
        if (model.hasdecay) {
            [0, 1, model.suslevel, 0]
        }{
            [0, 1, 0]
        }
    };

    gettimes = {
        var atkmapped, decmapped, relmapped;
        var atkspec = getspec.('atk');
        var relspec = getspec.('rel');
        //atkmapped = model.atk.linlin(0, atkspec.maxval, 0, 0.25);
        atkmapped = model.atk.linlin(0, 1, 0, 0.25);
        
        if (model.hasdecay) {
            decmapped = model.dec.linlin(0, 1, atkmapped, 0.5);
            //relmapped = model.rel.linlin(0, relspec.maxval, decmapped, 1);
            relmapped = model.rel.linlin(0, 1, decmapped, 1);
            [
                0,
                atkmapped,
                decmapped,
                relmapped
            ];
        }{
            //relmapped = model.rel.linlin(0, relspec.maxval, atkmapped, 1);
            relmapped = model.rel.linlin(0, 1, atkmapped, 1);
            [
                0,
                atkmapped,
                relmapped
            ];
        }
    };

    model.atk = getval.('atk');
    model.dec = getval.('dec');
    model.rel = getval.('rel');
    model.suslevel = getval.('suslevel');
    model.atkcurve = getval.('atkcurve');
    model.deccurve = getval.('deccurve');
    model.relcurve = getval.('relcurve');

    model.addDependant({|obj, what, val|
        setval.(what, val);
        //[what, val].debug("model changed");
    });

    envview = EnvelopeView()
    .keepHorizontalOrder_(true)
    .elasticSelection_(true)
    .editable_(true)
    .strokeColor_(node.color)
    .gridColor_(Color.gray)
    .background_(Color.clear)
    .thumbSize_(20)
    .grid_(Point(0.25, 0.25))
    .gridOn_(true)
    .step_(0.0001)
    .minHeight_(100)
    ;

    curves = getcurves.();
    levels = getlevels.();
    times = gettimes.(); 

    curvesupdater = {|obj, which|
        if (which == 0) {
            model.atkcurve = obj[which];
        } {
            if (which == (curves.size-1)) {
                model.relcurve = obj[which];
            } {
                model.deccurve = obj[which];
            }
        }
    };

    timesupdater = {|obj, which|
        if (which > 0) {
            if (which == 1) {
                //var val = times[which].linlin(0, 0.25, 0, 8);
                var val = times[which].linlin(0, 0.25, 0, 1);
                model.atk = val;
            } {
                if (which == (times.size-1)) {
                    var val;
                    var min = times[1]; // atk
                    if (model.hasdecay) {
                        min = times[2] // dec
                    };
                    //val = times[which].linlin(min, 1, 0, 8);
                    val = times[which].linlin(min, 1, 0, 1);
                    model.rel = val;
                } {
                    var val;
                    var atkmapped = times[1];
                    val = times[which].linlin(atkmapped, 0.5, 0, 1);
                    model.dec = val;   
                }
            }
        }
    };

    levelsupdater = {|obj, which|
        if (model.hasdecay) {
            if (which == 2) {
                model.suslevel = obj[which];
            }
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
        if (model.hasdecay) {
            if (index == 2) {
                if (ctrl.x > 0.5) {
                    ctrl.x = 0.5
                };
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
    });

    envview.setEditable(0, false);
    view.layout.add(envview);

    view.onClose_({
        //node.removeDependant(listener);
    })
}
)
