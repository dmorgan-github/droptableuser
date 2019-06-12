(
Fdef(\ezknob, {arg label="ezknob", action={}, val=0, spec=[0, 1, \lin, 0, 0.5].asSpec, cb={};
	var nb, k, st;
	var view = View().layout_(VLayout(
		st = StaticText().string_(label).align_(\center),
		k = Knob().mode_(\vert)
		.action_({arg ctrl;
			action.(ctrl, spec);
			nb.value = spec.map(ctrl.value);
		}).value_(spec.unmap(val)),
		nb = NumberBox().value_(val).action_({arg ctrl;
			k.valueAction_(spec.unmap(ctrl.value));
		})
	).margins_(1).spacing_(1));
	cb.(st, k, nb);
	view;
});
)