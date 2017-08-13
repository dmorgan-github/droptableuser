(
specsView: {arg specs, node, envir, mainView, status;

	var view = View()
	.layout_(VLayout().margins_(2).spacing_(2))
	.background_(Color.rand);

	specs.sortedKeysValuesDo({arg k,v;

		var layout = HLayout().margins_(2).spacing_(2);
		var nb = NumberBox().decimals_(3);
		var slider = Slider();
		var stack = StackLayout();
		var height = 20;
		var font = Font("Courier New", 10);

		// what is the right way to handle this?
		var spec = v.asSpec;
		var mapped = spec.unmap(spec.default).linlin(0,1,-1,1);
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

		NotificationCenter.register(mainView, k, slider, {arg val;
			slider.valueAction_(val.linlin(-1,1,0,1));
		});

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
					var val = ctrl.value;
					node.set(k.asSymbol, val.linlin(0,1,-1,1));
					nb.value_(v.asSpec.map(ctrl.value));
				})
				.value_(v.asSpec.unmap(v.asSpec.default))

			).mode_(\stackAll).index_(1)
		);

		layout.add(
			nb.fixedSize_(40@height).font_(font).action_({arg ctrl;
				slider.valueAction_(v.asSpec.unmap(ctrl.value))
			})
			.value_(v.asSpec.default)
		);

		view.layout.add(layout);

	});

	view;
},

presetsView: {arg node, config, mainView;

	var view = View().layout_(HLayout().margins_(2).spacing_(2));
	var presets = Array.fill(20, {nil});
	var buttons = List.new;
	var lastActive = -1;

	20.do({arg i;

		var button = Button().fixedSize_(10@10)
		.states_( [ ["", nil, Color.white ], ["", nil, Color.blue] ] )
		.action_({arg ctrl;

			var val = ctrl.value;
			if (presets[i].isNil) {
				// setting preset for first time
				presets[i] = node.getKeysValues;
				buttons[i].states = [ ["", nil, Color.blue] ];
			} {
				if (lastActive == i) {
					// updating preset
					presets[i] = node.getKeysValues;
				} {
					// changing to new preset
					var myPresets = presets[i];
					myPresets.do({arg kv;
						node.set(kv[0], kv[1]);
						NotificationCenter.notify(mainView, kv[0].asSymbol, kv[1]);
					});
				}
			};

			//presets.postln;
			lastActive = i;
		});

		if (config[\presets].isNil.not) {
			presets[i] = config[\presets][i];
			button.states_( [["", nil, Color.blue]] );
		};

		buttons.add(button);
		view.layout.add(button);
	});

	view;
},

playView: {arg name, node, status;

	var height = 20;
	var font = Font("Courrier New", 10);
	var wetKey = ("wet" ++ 100).asSymbol;
	var view = View().layout_(HLayout().margins_(2).spacing_(2));

	view.layout.add(StaticText().string_(name).font_(font));

	view.layout.add(
		Slider()
		.orientation_(\horizontal)
		.thumbSize_(10)
		.fixedSize_(50@height)
		.font_(font)
		.value_(1.linlin(0,4,0,1))
		.action_({arg ctrl;
			var val = ctrl.value.linlin(0,1,0,4);
			status.string_("vol: " ++ val.asString);
			node.vol = val;
		})
	);

	view.layout.add(
		Slider()
		.orientation_(\horizontal)
		.thumbSize_(10)
		.fixedSize_(50@height)
		.font_(font)
		.value_(1.linlin(0.1, 8, 0, 1))
		.action_({arg ctrl;
			var val = ctrl.value.linlin(0, 1, 0.1, 8);
			node.fadeTime = val;
			status.string_("fadetime: " ++ val.asString);
		})
	);

	view.layout.add(

		Slider()
		.orientation_(\horizontal)
		.thumbSize_(10)
		.fixedSize_(50@height)
		.font_(font)
		.value_(1)
		.action_({arg ctrl;
			node.set(wetKey, ctrl.value);
			status.string_("wet: " ++ ctrl.value.asString);
		})
	);

	view.layout.add(
		Button()
		.fixedSize_(30@height)
		.states_([ ["play"], ["stop"] ])
		.font_(font)
		.string_("play")
		.action_({arg ctrl;
			if (ctrl.value == 1) {
				node.play;
			} {
				node.stop;
			}
		})
	);

	view.layout.add(
		Button()
		.fixedSize_(30@height)
		.font_(font)
		.string_("doc")
		.mouseDownAction_({arg ctrl; node.document; })
	);

	view;
}

);//[\playView].( \bobo, (), View()).front;

