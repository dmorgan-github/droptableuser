(
view: {arg name, envir, config;

	var view, subview;
	var font = Font("Courrier New", 10);
	var height = 20;
	var status = StaticText().font_(font).string_("");

	var controlsView = {arg node, config;

		var view = View().layout_(VLayout().margins_(2).spacing_(2));
		var specs = config[\specs];
		var func = config[\func];

		node[0] = func;
		specs.keysValuesDo({arg k,v;

			var layout = HLayout();
			var nb = NumberBox();
			var slider = Slider();
			var lfostack = StackLayout();

			// what is the right way to handle this?
			var spec = v.asSpec;
			var mapped = spec.default.linlin(spec.minval, spec.maxval, -1, 1);
			node.set(k, mapped);

			layout.add(

				lfostack.add(
					TextField()
					.minWidth_(40)
					.maxHeight_(20)
					.font_(font)
					.action_({arg ctrl;

						var val = ctrl.value;
						if (val.size > 0) {

							var lfo, name;
							val = val.asSymbol;
							lfo = envir[val];
							if (lfo.isNil.not) {
								slider.enabled_(false);
								nb.enabled_(false);
								node.set(k,lfo);
							} {
								"node % doesn't exist in environment".format(val).error;
							}
						} {
							slider.enabled_(true);
							nb.enabled_(true);
							node.unmap(k)
						}
					})
					.mouseUpAction_({arg view,x,y,mod;

						// alt 524288
						if (mod == 524288) {
							lfostack.index = 1;
						}
					});
				);

				lfostack.add(
					RangeSlider()
					.fixedSize_(60@height)
					.orientation_(\horizontal)
					.mouseUpAction_({arg view,x,y,mod;

						// alt 524288
						if (mod == 524288) {
							lfostack.index = 0;
						}
					})
					.action_({arg ctrl;

						var spec = v.asSpec;
						var lo = spec.map(ctrl.lo);
						var hi = spec.map(ctrl.hi);
						var key_lo = (k ++ '_min').asSymbol;
						var key_hi = (k ++ '_max').asSymbol;
						node.set(key_lo, lo, key_hi, hi);
						status.string_(lo.asString ++ " : " + hi.asString);

						status.string_(lo.trunc(0.001).asString
							++ " : " ++ hi.trunc(0.001).asString);
					})
					.lo_(v.asSpec.unmap(v.asSpec.minval))
					.hi_(v.asSpec.unmap(v.asSpec.maxval));
				);
			);

			layout.add(

				StackLayout(
					StaticText()
					.string_(k)
					.font_(font)
					.minWidth_(50)
					.align_(\center),

					slider
					.orientation_(\horizontal)
					.thumbSize_(10)
					.minWidth_(50)
					.maxHeight_(20)
					.font_(font)
					.background_(Color.blue.alpha_(0.0))
					.action_({arg ctrl;
						// Not sure if this is best way to set values
						var val = ctrl.value.linlin(0,1,-1,1);
						node.set(k.asSymbol, val);
						nb.value_(v.asSpec.map(ctrl.value));
					})
					.value_(v.asSpec.unmap(v.asSpec.default))

				).mode_(\stackAll).index_(1)
			);
			layout.add(
				nb.minWidth_(25).font_(font).action_({arg ctrl;
					slider.valueAction_(v.asSpec.unmap(ctrl.value))
				})
				.value_(v.asSpec.default)
			);
			view.layout.add(layout);
		});
		view;
	};

	envir[name] = NodeProxy.control;
	view = View().layout_(VLayout().margins_(2).spacing_(2))
	.onClose_({
		envir[name].clear;
		envir[name] = nil;
	});
	view.layout.add(HLayout(
		StaticText().string_(name).font_(font),
		Button()
		.maxWidth_(10)
		.maxHeight_(10)
		.mouseDownAction_({arg ctrl; envir[name].document; })
	));

	subview = controlsView.(envir[name], config);
	view.layout.add(subview);
	view.layout.add(status);
	view;
};
)

