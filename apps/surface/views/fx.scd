(
view: {arg name, envir, config;

	var view, horizontalView, inputs, controls;
	var font = Font("Courrier New", 10);
	var height = 20;
	var status = StaticText().font_(font).string_("");
	var filterSlot = 100;

	var controlsView = {arg node, config;

		var specs = config[\specs];
		var func = config[\func];
		var view = View().layout_(VLayout().margins_(2).spacing_(2))
		.background_(Color.rand)
		.minWidth_(200)
		.maxWidth_(200);

		node[filterSlot] = \filter -> func;

		specs.keysValuesDo({arg k,v;

			var layout = HLayout();
			var nb = NumberBox();
			var slider = Slider();
			var stack = StackLayout();

			// what is the right way to handle this?
			var spec = v.asSpec;
			var mapped = spec.default.linlin(spec.minval, spec.maxval, -1, 1);
			node.set(k, mapped);

			layout.add(

				stack.add(
					TextField()
					.fixedSize_(60@height)
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
								status.string_("node % doesn't exist in environment".format(val));
							}
						} {
							"here".postln;
							slider.enabled_(true);
							nb.enabled_(true);
							node.unmap(k)
						}
					})
					.mouseUpAction_({arg view,x,y,mod;

						// alt 524288
						if (mod == 524288) {
							stack.index = 1;
						} {
							status.string_("alt + click to set range");
						}
					});
				);

				stack.add(
					RangeSlider()
					.fixedSize_(60@height)
					.background_(Color.white.alpha_(0))
					.orientation_(\horizontal)
					.mouseUpAction_({arg view,x,y,mod;

						// alt 524288
						if (mod == 524288) {
							stack.index = 0;
						} {
							status.string_(view.lo.trunc(0.001).asString ++ " : " + view.hi.trunc(0.001).asString);
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
					})
					.lo_(v.asSpec.unmap(v.asSpec.minval))
					.hi_(v.asSpec.unmap(v.asSpec.maxval))
				);
			);

			layout.add(

				StackLayout(
					StaticText()
					.string_(k)
					.font_(font.bold_(true))
					.minWidth_(50)
					.align_(\center),

					slider
					.orientation_(\horizontal)
					.thumbSize_(10)
					.fixedSize_(100@height)
					.font_(font)
					.background_(Color.white.alpha_(0.0))
					.action_({arg ctrl;
						// Not sure if this is best way to set values
						var val = ctrl.value.linlin(0,1,-1,1);
						node.set(k.asSymbol, val);
						nb.value_(v.asSpec.map(ctrl.value));
					})
					.value_(v.asSpec.unmap(v.asSpec.default))
					//.valueAction_();

				).mode_(\stackAll).index_(1)
			);
			layout.add(
				nb.fixedSize_(30@height).font_(font).action_({arg ctrl;
					slider.valueAction_(v.asSpec.unmap(ctrl.value))
				})
				.value_(v.asSpec.default)
			);
			view.layout.add(layout);
		});

		view;
	};

	var inputsView = {arg node;

		var view = View().layout_(VLayout().margins_(2).spacing_(2)).background_(Color.rand);

		4.do({arg i;

			view.layout.add(
				HLayout(
					TextField()
					.fixedSize_(60@height)
					.font_(font)
					.action_({arg ctrl;
						var val = ctrl.value;
						if ( envir[val.asSymbol].isNil) {
							var msg = "node " + val + " does not exit";
							status.string_("node " + val + " does not exit");
							msg.error;
						} {
							node[i] = { envir[val.asSymbol].ar * (\vol_ ++ i).asSymbol.kr(1) };
						}
					}),

					Slider()
					.fixedSize_(25@height).font_(font)
					.thumbSize_(10)
					.value_(1)
					.action_({arg ctrl;
						envir[name].set( (\vol_ ++ i).asSymbol, ctrl.value );
						status.string_("mix : " + ctrl.value.asString);
					});
				)
			, align:\top);
		});

		view;
	};

	envir[name] = NodeProxy.audio;
	view = View().layout_(VLayout().margins_(2).spacing_(2))
	.onClose_({
		envir[name].clear;
		envir[name] = nil;
	});
	view.layout.add(HLayout(

		StaticText().string_(name).font_(font),

		Slider()
		.orientation_(\horizontal)
		.thumbSize_(10)
		.fixedSize_(50@height)
		.font_(font)
		.value_(1.linlin(0,4,0,1))
		.action_({arg ctrl;
			status.string_("vol: " ++ ctrl.value.asString);
			envir[name].vol = ctrl.value.linlin(0,1,0,4);
		}),

		Slider()
		.orientation_(\horizontal)
		.thumbSize_(10)
		.fixedSize_(50@height)
		.font_(font)
		.value_(1)
		.action_({arg ctrl;
			var key = ('wet' ++ filterSlot).asSymbol;
			envir[name].set(key, ctrl.value);
			status.string_("wet: " ++ ctrl.value.asString);
		}),

		Button()
		.fixedSize_(30@height)
		.states_([ ["play"], ["stop"] ])
		.font_(font)
		.string_("play")
		.action_({arg ctrl;
			if (ctrl.value == 1) {
				envir[name].play;
			} {
				envir[name].stop;
			}
		}),

		Button()
		.fixedSize_(30@height)
		.font_(font)
		.string_("doc")
		.mouseDownAction_({arg ctrl; envir[name].document; })
	));

	inputs = inputsView.(envir[name]);
	controls = controlsView.(envir[name], config);

	horizontalView = View().layout_(HLayout().margins_(2).spacing_(2));
	horizontalView.layout.add(inputs);
	horizontalView.layout.add(controls);

	view.layout.add(horizontalView);
	view.layout.add(status);

	view;
};
)


