(
q = q ? ();

~slider = {arg spec;

	var label = spec.units;
	var slider = EZSlider(nil, 45@300, label, controlSpec: spec, unitWidth: 30, numberWidth: 60, layout: \vert);

	q[label.asSymbol] = q[label.asSymbol] ? Bus.control(s);

	slider.setColors(Color.grey, Color.white, Color.grey(0.7), Color.grey, Color.white, Color.yellow, nil, nil, Color.grey(0.7));
	slider.window.bounds = slider.window.bounds.moveBy(250,50);
	slider.font_(Font("Helvetica",10));
	slider.action_({arg ctrl;

		var val = ctrl.value;
		q[label.asSymbol].set(val);
	});
};
);

~slider.( ControlSpec.new(minval:0.05, maxval: 1, step:0.01, default: 0.1, units: "graindur") );