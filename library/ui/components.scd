(
Fdef(\ctrlview, {arg key, spec, color, val, cb={};

	var controlSpec = spec;
	var myval = val ?? controlSpec.default;

	var stack, view;
	var font = Font(size:8);
	var li = LevelIndicator().value_(controlSpec.unmap(myval));
	var labelView = StaticText().string_(key ++ ": ").font_(font).stringColor_(Color.white);
	var st = StaticText().string_(myval.trunc(0.001)).font_(font).stringColor_(Color.white);
	var nb = NumberBox()
	.font_(font)
	.value_(myval)
	.background_(Color.white)
	.minDecimals_(3)
	.clipLo_(controlSpec.minval)
	.clipHi_(controlSpec.maxval);
	var dragsrc;

	//envir[key] = myval;
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
				//envir[key] = mappedVal;
				cb.(key, mappedVal);
			};
		})
		.mouseDownAction_({arg ctrl, x, y, mod, num, count;
			var val = controlSpec.default;
			if (count == 2) {
				li.value = controlSpec.unmap(val);
				st.string_(val.trunc(0.001));
				nb.value = val;
				//envir[key] = val;
				cb.(key, val);
			} {
				if (mod == 0) {
					var val = x.linlin(0, ctrl.bounds.width, 0, 1);
					var mappedVal = controlSpec.map(val);
					li.value = val;
					st.string_(mappedVal.trunc(0.001));
					nb.value = mappedVal;
					//envir[key] = mappedVal;
					cb.(key, mappedVal);
				};
			};
		}),
		nb
		.action_({arg ctrl;
			var val = ctrl.value;
			li.value = controlSpec.unmap(val);
			st.string_(val);
			//envir[key] = val;
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
			}
		}).fixedHeight_(25)
	).margins_(0).spacing_(1));

	view;

});

Fdef(\ngui, {arg node;

	var win;
	var palette = QPalette.auto(Color.grey, Color.black);
	var ctrlView = Fdef(\ctrlview);
	var scrollView = ScrollView(bounds:Rect(0,0,160,300));
	var view = View().layout_(VLayout().margins_(0.2).spacing_(0.2));
	var cb = {arg key, val;
		node.set(key, val)
	};

	node.controlNames.do({arg cn;
		var k = cn.name;
		var v = node.getSpec(k) ? [0, 1, \lin, 0, 1];
		var val = node.get(k);
		var ctrl = ctrlView.(k, v.asSpec, Color.rand, val, cb);
		view.layout.add(ctrl);
	});

	view.layout.add(nil);
	scrollView.canvas = view.background_(Color.clear);
	scrollView;

	win = View().layout_(VLayout().margins_(2).spacing_(2))
	.palette_(palette)
	.minWidth_(150)
	.minHeight_(250)
	.name_(node.key);

	win.layout.add(scrollView);
	win.front;
});

)


Fdef(\ngui).(~kjp);