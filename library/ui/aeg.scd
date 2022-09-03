(
func: {|node|
    var curves, levels, times;
    var view = View().layout_(VLayout().spacing_(0).margins_(0));
    var atkspec, relspec, atkcurvespec, relcurvespec;
    var listener;

    var envview = EnvelopeView()
    .keepHorizontalOrder_(true)
    .editable_(false)
    .strokeColor_(node.color)
    .gridColor_(Color.gray)
    .background_(Color.clear)
    .thumbSize_(20)
    .grid_(Point(0.25, 0.25))
    .gridOn_(true)
    .step_(0.0001);

    listener = {|obj, what, vals|
        if (what == \set) {
            vals.pairsDo({|k, v|
                if (k == \rel) {
                    times[times.size-1] = v;
                };
                if (k == \atk) {
                    times[1] = v;
                };
                if (k == \dec) {
                    times[2] = v;
                };
                if (k == \suslevel) {
                    levels[2] = v
                };
                if (k == \relcurve) {
                    curves[curves.size-1] = v;
                };
                if (k == \deccurve) {
                    curves[1] = v;
                };
                if (k == \atkcurve) {
                    curves[0] = v;
                };
                envview.curves = curves;
                envview.value = [ times, levels ];
            })
        }
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

    envview.value = [ times, levels ];
    envview.curves = curves;
    view.layout.add(envview);

    node.addDependant(listener);

    view.onClose_({
        node.removeDependant(listener);
    })
}
)