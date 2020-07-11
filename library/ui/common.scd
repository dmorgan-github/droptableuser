(
Fdef(\baseview, {arg view, title, w, h;

	var mousey, mousex;
	var width = w ? view.sizeHint.width;
	var height = h ? view.sizeHint.height;
	var top = Window.screenBounds.height * 0.5;
	var left = Window.screenBounds.width * 0.3;
	var win = Window.new(title, bounds:Rect(left, top, width, height), border:false);

	var outerview = View().layout_(
		VLayout(
			HLayout(
				StaticText().string_(title),
				nil,
				Button().states_([ ["x", Color.white, nil] ])
				.action_({ win.close })
				.maxWidth_(25)
			).margins_(2).spacing_(1),
			view
		).margins_(0).spacing_(0)
	)
	.mouseDownAction_({arg ctrl, x, y;
		mousey = ctrl.sizeHint.height - y;
		mousex = x;

		//[win.bounds.top, mousey].postln;
	})
	.mouseMoveAction_({arg ctrl, x, y;

		var height = ctrl.sizeHint.height;
		var top = ctrl.sizeHint.height - y;
		var left = win.bounds.left + x - mousex;
		var width = ctrl.sizeHint.width;
		top = win.bounds.top + (top - mousey);
		//top = win.bounds.top + top;
		//if (top > (Window.screenBounds.height - height)) {
		//	top = Window.screenBounds.height - height;
		//};
		//[top].postln;
		//[mousey, top, top - mousey].postln;

		win.bounds = Rect(left, top, width, height);
		true;
	});
	win.layout = VLayout(outerview).margins_(0).spacing_(0);
	win.asView.palette_(QPalette.dark);
});

Fdef(\ctrlview, {arg key, spec, color, val, cb;

	var controlSpec = spec;
	var myval = val ?? controlSpec.default;

	var stack, view;
	var font = Font(size:8);
	var li = LevelIndicator().value_(controlSpec.unmap(myval));
	var label = if (key.asString.size > 0) {key ++ ": "}{""};
	var labelView = StaticText().string_(label).font_(font).stringColor_(Color.white);
	var st = StaticText().string_(myval.trunc(0.001)).font_(font).stringColor_(Color.white);
	var nb = NumberBox()
	.font_(font)
	.value_(myval)
	.background_(Color.white)
	.minDecimals_(3)
	.clipLo_(controlSpec.minval)
	.clipHi_(controlSpec.maxval);

	stack = StackLayout(
		View()
		.layout_(
			StackLayout(
				View().layout_(HLayout(labelView, st, nil).margins_(1).spacing_(1)),
				li
				.style_(\continuous)
				.meterColor_(color.alpha_(0.5))
				.warningColor_(color.alpha_(0.5))
				.criticalColor_(color.alpha_(0.5))
				.background_(color.alpha_(0.2))
			)
			.mode_(\stackAll)
			.margins_(0)
			.spacing_(0)
		)
		.mouseMoveAction_({arg ctrl, x, y, mod;
			var val = x.linlin(0, ctrl.bounds.width, 0, 1);
			var mappedVal = controlSpec.map(val);
			if (mod == 0) {
				li.value = val;
				st.string_(mappedVal.trunc(0.001));
				nb.value = mappedVal;
				cb.(key, mappedVal);
			};
			true;
		})
		.mouseDownAction_({arg ctrl, x, y, mod, num, count;
			var val = controlSpec.default;
			if (count == 2) {
				li.value = controlSpec.unmap(val);
				st.string_(val.trunc(0.001));
				nb.value = val;
				cb.(key, val);
			} {
				if (mod == 0) {
					var val = x.linlin(0, ctrl.bounds.width, 0, 1);
					var mappedVal = controlSpec.map(val);
					li.value = val;
					st.string_(mappedVal.trunc(0.001));
					nb.value = mappedVal;
					cb.(key, mappedVal);
					true;
				};
			};
		}),
		nb
		.action_({arg ctrl;
			var val = ctrl.value;
			li.value = controlSpec.unmap(val);
			st.string_(val);
			cb.(key, val);
			stack.index = 0;
		}),
	).mode_(\stackOne)
	.margins_(0)
	.spacing_(0);

	view = View().layout_(HLayout(
		View()
		.layout_(stack)
		.mouseDownAction_({arg ctrl, x, y, mod, num, count;
			if (mod == 262144) {
				stack.index = 1;
			};
			true;
		}).fixedHeight_(25)
	).margins_(0).spacing_(1));

	view;
});

Fdef(\playview, {arg node;

	var view = View().layout_(
		HLayout(
			Button().states_([
				[">"],
				["[]"]
			]).action_({arg ctrl;
				if (ctrl.value == 1) {
					node.play;
				} {
					node.stop;
				}
			})
			.value_(node.isMonitoring.asInteger)
			.maxHeight_(18)
			.maxWidth_(25),
			Slider()
			.orientation_(\horizontal)
			.thumbSize_(7)
			.action_({arg ctrl;
				node.vol = ctrl.value;
			})
			.value_(node.vol)
			.minWidth_(50),

			Slider()
			.orientation_(\horizontal)
			.thumbSize_(7)
			.maxWidth_(20)
			.action_({arg ctrl;
				node.fadeTime = ctrl.value;
			})
			.value_(node.fadeTime)
			.minWidth_(50),
		)
	);
	view;
});
)